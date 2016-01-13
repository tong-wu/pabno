class Question
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short
  store_in collection: "questions"

  # include SaveVotes
  include AwsHelper

  field :t, as: :text, type: String
  field :o, as: :options, type: Hash
  field :i, as: :image, type: String
  field :r, as: :ranking, type: Integer
  field :s, as: :status

  belongs_to :user, index:true
  enumerize :status, in: [:active, :closed, :blocked], default: :active

  def ask(params, user)
    #todo: error handling here and most other functions ಠ_ಠ
    c_time = Time.now.to_i
    create!(
        text: params[:text],
        options: {
            yes: 0,
            no: 0,
        },
        image: store_image(params[:image]),
        ranking: c_time,
        status: 'active'
    )
    REDIS_QUESTIONS_RANK.zincrby('top', c_time, self.id.to_s)
    REDIS_QUESTIONS_RANK.lpush('new', self.id.to_s)
    REDIS_QUESTIONS_RANK.ltrim('new', 0, 10000)

    user.questions.push(self)
    reload
  end

  #todo: Refactor to concerns for anything votes related (votes, yes_no_ratio, yes, no, place_vote)
  def votes
    total_votes = 0
    self.options.each do |vote_val|
      #todo: this is probably wrong
      total_votes += vote_val.to_i
    end
    total_votes += (REDIS_VOTES.get('YES:' + self.id).to_i + REDIS_VOTES.get('NO:' + self.id).to_i)
  end

  #This will only work if we have 2 options. Initially limit to 2
  def yes_no_ratio
    yes = self.options[:yes].to_i + REDIS_VOTES.get('YES:' + self.id).to_i
    no = self.options[:no].to_i + REDIS_VOTES.get('NO:' + self.id).to_i

    total = yes + no
    total = total == 0 ? 1 : total

    ratio = {
        yes:  ((yes / total) * 100).round(0),
        no:   ((no / total) * 100).round(0)
    }
  end



  def store_image(image)
    #todo: AWS s3 for store and lambda to resize
  end

  def self.find_from_cache(id)
    if REDIS_QUESTIONS.get("q-data:#{id}").nil?
      question = Question.find(id)
      REDIS_QUESTIONS.set("q-data:#{id}", question)
      REDIS_QUESTIONS.expire("q-data:#{id}", 60)
    end

    REDIS_QUESTIONS.get("q-data:#{id}")
  end

  def self.top_list(page)
    #todo: if there is no top list build it out
    #todo: MUCH CLEANUP HERE
    top_questions = REDIS_QUESTIONS_RANK.zrevrange("top", (page - 1) * 20, (page * 20) - 1)
    if top_questions.nil?
      top = Question.page(page).per(20)
      top.each do |q|
        REDIS_QUESTIONS_RANK.zadd("top", q.ranking.to_i, q.id.to_s)
        top_questions << q.id.to_s
      end
    end
    top_array = Array.new
    top_questions.each do |q|
      top_array << Question.find_from_cache(q)
    end
  end

  def self.new_list(page)
    new_questions = REDIS_QUESTIONS_RANK.lrange('new', (page - 1) * 20, (page * 20) - 1)
    new_array = Array.new
    new_questions.each do |q|
      new_array << Question.find_from_cache(q)
    end
  end

  def yes
    self.options[:yes] + REDIS_VOTES.get('YES:' + self.id)
  end

  def no
    self.options[:no] + REDIS_VOTES.get('NO:' + self.id)
  end

  # Note that these yes/no defs store votes in redis for storage in time intervals.
  # The number stored in redis is the number of NEW yes/no votes to be recorded
  def place_vote(user_id, option)
    if REDIS_VOTES.get("VOTES:#{self.id}").nil?
      Resque.enqueue_in(30.seconds, SaveVotes, :question_id => self.id)
    end

    REDIS_VOTES.incr("VOTES:#{self.id}")
    case option
      when QuestionOption::YES
        REDIS_VOTES.incr("YES:#{self.id}")
      when QuestionOption::NO
        REDIS_VOTES.incr("NO:#{self.id}")
    end

    #todo: refactor this into a service
    aws_send_vote(user_id, 1, self.id)
  end

end

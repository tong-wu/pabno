class Question
  include Mongoid::Document
  store_in collection: "questions"

  include AwsHelper

  field :t, as: :text, type: String
  field :o, as: :options, type: Hash
  field :i, as: :image, type: String

  belongs_to :user, index:true

  def ask(params)
    #todo: error handling
    create!(
        text: params[:text],
        options: {
            yes: 0,
            no: 0,
        },
        image: store_image(params[:image])
    )
  end

  def votes
    total_votes = 0
    self.options.each do |vote_val|
      total_votes += vote_val.to_i
    end
    total_votes += (REDIS_VOTES.get('YES:' + self.id).to_i + REDIS_VOTES.get('NO:' + self.id).to_i)
  end

  #This will only work if we have 2 options. Initially limit to 2
  def yes_no_ratio
    yes = self.options[:yes] + REDIS_VOTES.get('YES:' + self.id).to_i
    no = self.options[:no] + REDIS_VOTES.get('NO:' + self.id).to_i

    ratio = (yes.to_i/no.to_i)
  end



  def store_image(image)
    #todo: s3 for store and lambda to resize
    "None"
  end

  def yes
    self.options[:yes] + REDIS_VOTES.get('YES:' + self.id)
  end

  def no
    self.options[:no] + REDIS_VOTES.get('NO:' + self.id)
  end

  # Note that these yes/no defs store votes in redis for storage in time intervals.
  # The number stored in redis is the number of NEW yes/no votes to be recorded
  def vote_yes(user_id)
    if REDIS_VOTES.get("YES:#{self.id}")
      REDIS_VOTES.incr("YES:#{self.id}")
    else
      REDIS_VOTES.set("YES:#{self.id}", 1)
      #todo: resque-scheduler
    end
    aws_send_vote(user_id, 1)
  end

  def vote_no(user_id)
    if REDIS_VOTES.get("NO:#{self.id}")
      REDIS_VOTES.incr("NO:#{self.id}")
    else
      REDIS_VOTES.set("NO:#{self.id}", 1)
      #todo: resque-scheduler
    end
    aws_send_vote(user_id, 0)
  end

  # This one only saves the count in mongodb. No need to batch the cassandra inserts
  # since the cassandra db is so fast on inserts.
  def save_redis_votes
    yes = REDIS_VOTES.get("YES:#{self.id}")
    if yes
      self.options[:yes] += yes
    end

    no = REDIS_VOTES.get("NO:#{self.id}")
    if no
      self.options[:no] += no
    end

    if save
      #todo: not sure how to handle this yet. Data could be lost between redis key delete and last counted that we stored.
      #Probably not a big deal and we can just deal with the 1-2 lost votes.
    end
  end

  def self.find_from_cache(id)
    if REDIS_QUESTIONS.get("q-data:#{id}") == nil
      question = Question.find(id.to_i)
      REDIS_QUESTIONS.set("q-data:#{id}", question.to_json)
      REDIS_QUESTIONS.expire("q-data:#{id}", 120)
    end

    REDIS_QUESTIONS.get("q-data:#{id}")
  end

  def self.top_list(start, stop)
    top_questions = REDIS_QUESTIONS_RANK.zrevrange("top", start, stop)
    top_array = Array.new
    top_questions.each do |q|
      top_array << Question.find_from_cache(q)
    end
  end
end

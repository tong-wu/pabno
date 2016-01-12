class User
  include Mongoid::Document
  include Mongoid::Timestamps::Short
  extend Enumerize

  field :uid
  field :u, as: :username, type: String
  field :y, as: :last_login, type: DateTime, :default => Time.now
  field :a, as: :age
  field :g, as: :gender
  field :l, as: :location
  field :p, as: :provider, type: String
  field :d, as: :device_tokens, type: Array
  field :t, as: :oauth_token
  field :s, as: :account_status

  has_many :questions, dependent: :destroy, autosave: true
  has_and_belongs_to_many :friends, class_name: 'User'

  index({ location:"2d" }, { min: -200, max: 200, background: true })
  index({ age:1 }, { background: true })
  index({ username:1 }, { unique:true, background:true })
  index({ uid:1 }, { unique:true, background:true })

  enumerize :account_status, in: [:active, :disabled, :restricted], default: :active

  def self.from_token(auth, provider = 'facebook')
    @koala = Koala::Facebook::API.new(auth, ENV['FB_SECRET'])
    @fb_user = @koala.get_object("me")

    #todo: Check that the token is not expired
    where(provider: provider, uid: @fb_user.id).first_or_create do |user|
      user.provider = provider
      user.uid = @fb_user['id']
      user.age = @fb_user['age_range']
      user.gender = @fb_user['gender']
      user.location = @fb_user['location']
      user.oauth_token = auth
      user.account_status = user.account_status.nil? ? 'active' : user.account_status
      user.last_login = Time.now
      user.save!
    end
  end

  def info
    info = {
        username: username,
        age: age,
        location: location,
        last_activity: last_activity,
        gender: gender,
    }
  end

  def disable_account
    account_status = 'disabled'
    save!
  end

  def limit_account
    account_status = 'restricted'
    save!
  end

  def yes_no_ratio
    yes = no = 0
    questions.each do |question|
      yes += question.options[:yes]
      no += question.options[:no]
    end

    no = no.to_i == 0 ? 1 : no.to_i

    ratio = (yes.to_i/no.to_i).round(2)
  end

  #todo: Not sure if we really want to spend the extra time here to handle failed votes
  #Might be something better left for the first update... just show all votes as success for now?
  def cast_vote(question_id, vote)
    votes = REDIS_USER_VOTES.smembers("user-votes:#{uid}")
    if votes.nil?
      votes = get_votes_history
    end
    if !votes.include? question_id.to_i
      REDIS_USER_VOTES.sadd("user-votes:#{uid}", question_id.to_i)
      if REDIS_QUESTIONS_RANK.zscore('top', question_id.to_i)
        REDIS_QUESTIONS_RANK.zincrby('top', 10, question_id.to_i)
      else
        REDIS_QUESTIONS_RANK.zadd('top', Question.find(question_id.to_i).ranking + 10, question_id.to_i)
      end
    end

    if vote == 1
      Question.find(question_id).vote(id, 1)
    elsif vote == 0
      Question.find(question_id).vote(id, 0)
    end
  end

  def add_friend(friend_id)
    friend = User.find(friend_id)
    friends.push(friend)
    save!
  end

  def get_votes_history
    response = Array.new
    loop do
      #todo: what if over 100? I don't have query offset yet. Add it soon
      resp = AWS_DYNAMO.query({
                                  table_name: AWS_DYNAMO_VOTES_BY_USER_TBL,
                                  limit: 100,
                                  scan_index_forward: "false",
                                  key_conditions: {
                                      "user_id" => {
                                          attribute_value_list: [id],
                                          comparison_operator: "EQ"
                                      },
                                  }
                              })
      response << resp
      break if resp.count < 1
      #todo: REDIS_USER_VOTES.sadd("user-votes:#{uid}", question_id.to_i)
    end
    response
  end
end
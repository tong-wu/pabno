class User
  include Mongoid::Document

  field :uid
  field :u, as: :username, type: String
  field :y, as: :last_activity, type: DateTime, :default => Time.now
  field :a, as: :age
  field :g, as: :gender
  field :l, as: :location
  field :p, as: :provider, type: String
  field :d, as: :device_tokens, type: Array
  field :t, as: :oauth_token
  field :e, as: :oauth_expires_at

  has_many :questions, dependent: :destroy, autosave: true
  has_and_belongs_to_many :friends, class_name: 'User'

  index({ location:"2d" }, { min: -200, max: 200, background: true })
  index({ age:1 }, { background: true })
  index({ username:1 }, { unique:true, background:true })
  index({ uid:1 }, { unique:true, background:true })

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.age = auth.age_range.to_s
      user.gender = auth.gender
      user.location = auth.location
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  def info
    info = {
        username: self.username,
        age: self.age,
        location: self.location,
        last_activity: self.last_activity,
        gender: self.gender,
    }
  end

  def yes_no_ratio
    yes = no = 0
    self.questions.each do |question|
      yes += question.options[:yes]
      no += question.options[:no]
    end
    ratio = (yes.to_i/no.to_i).round(2)
  end

  #todo: Not sure if we really want to spend the extra effort here to do a clean cacheing and vote casting...
  #While it does reduce upfront cost, might be something better left for the first update. First release won't get too many users
  def cast_vote(question_id, vote)
    votes = REDIS_USER_VOTES.smembers("user-votes:#{self.uid}")
    if votes.nil?
      votes = self.get_votes_history
    end
    if !votes.include? question_id
      REDIS_USER_VOTES.sadd("user-votes:#{self.uid}", question_id.to_s)
      REDIS_QUESTIONS_RANK.zincrby('top', 10, question_id.to_s)
    end

    if vote == 1
      Question.find(question_id).vote(self.id, 1)
    elsif vote == 0
      Question.find(question_id).vote(self.id, 0)
    end
  end

  def add_friend(friend_id)
    friend = User.find(friend_id)
    self.friends << friend.to_json
    save!
  end

  def get_votes_history
    response = Array.new
    loop do
      resp = AWS_DYNAMO.query({
                                  table_name: AWS_DYNAMO_VOTES_BY_USER_TBL,
                                  limit: 1000,
                                  scan_index_forward: "false",
                                  key_conditions: {
                                      "user_id" => {
                                          attribute_value_list: [self.id],
                                          comparison_operator: "EQ"
                                      },
                                  }
                              })
      response << resp
      break if resp.count < 1
    end
    response
  end
end
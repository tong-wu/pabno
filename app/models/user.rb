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

  has_many :q, class_name: Question, as: :questions, autosave: true

  index({ location:"2d" }, { min: -200, max: 200, background: true })
  index({ age:1 }, { background: true })
  index({ username:1 }, { unique:true, background:true })

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

  def update

  end

  def info
    info = {
        username: self.username,
        age: self.age,
        location: self.location,
        last_activity: self.last_activity
    }
  end

  def yes_no_ratio
    yes = no = 0
    self.questions.each do |question|
      yes += question.options[:yes]
      no += question.options[:no]
    end
    ratio = yes.to_i/no.to_i
  end
end
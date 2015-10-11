class User
  include Mongoid::Document

  field :u, as: :username, type: String
  field :y, as: :last_activity, type: DateTime, :default => Time.now
  field :a, as: :age, type: Integer, :default => 0
  field :g, as: :gender, type: Integer, :default => 0
  field :l, as: :location, type: Array
  field :f, as: :fb_token, type: String, :default => ''
  field :d, as: :device_tokens, type: Array

  has_many :q, class_name: Question, as: :questions, autosave: true

  index({ location:"2d" }, { min: -200, max: 200, background: true })
  index({ age:1 }, { background: true })
  index({ username:1 }, { unique:true, background:true })

  def create

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
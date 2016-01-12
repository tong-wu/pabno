case Rails.env
  when 'production'
    # REDIS                 = Redis.new(:host => "localhost", :port => 6379)
    # REDIS_VOTES           = Redis.new(:host => "localhost", :port => 6379)
    # REDIS_QUESTIONS       = Redis.new(:host => "localhost", :port => 6379)
    # REDIS_QUESTIONS_RANK  = Redis.new(:host => "localhost", :port => 6379)
    # REDIS_USER_VOTES      = Redis.new(:host => "localhost", :port => 6379)
    # REDIS_LOGIN           = Redis.new(:host => "localhost", :port => 6379)
  else
    REDIS                 = Redis.new(:host => "localhost", :port => 6379)
    REDIS_VOTES           = Redis.new(:host => "localhost", :port => 6379)
    REDIS_QUESTIONS       = Redis.new(:host => "localhost", :port => 6379)
    REDIS_QUESTIONS_RANK  = Redis.new(:host => "localhost", :port => 6379)
    REDIS_USER_VOTES      = Redis.new(:host => "localhost", :port => 6379)
    REDIS_LOGIN           = Redis.new(:host => "localhost", :port => 6379)
end

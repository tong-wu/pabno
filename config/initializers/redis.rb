case Rails.env
  when 'production'
    # REDIS_CHAT  = Redis.new(:host => "tydy-test.nkzhtn.ng.0001.usw2.cache.amazonaws.com",        :port => 6379, :db => 1)
    # REDIS_PROD  = Redis.new(:host => "tydy-test.nkzhtn.ng.0001.usw2.cache.amazonaws.com",        :port => 6379, :db => 2)
    # REDIS_ADMIN = Redis.new(:host => "tydy-admin-stats.nkzhtn.ng.0001.usw2.cache.amazonaws.com", :port => 6379)
    # REDIS       = Redis.new(:host => "tydy-test.nkzhtn.ng.0001.usw2.cache.amazonaws.com",        :port => 6379, :db => 3)
  else
    REDIS                 = Redis.new(:host => "localhost", :port => 6379)
    REDIS_VOTES           = Redis.new(:host => "localhost", :port => 6379)
    REDIS_QUESTIONS       = Redis.new(:host => "localhost", :port => 6379)
    REDIS_QUESTIONS_RANK  = Redis.new(:host => "localhost", :port => 6379)
    REDIS_USER_VOTES      = Redis.new(:host => "localhost", :port => 6379)
end

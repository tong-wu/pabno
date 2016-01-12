source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

#Mongodb for users and questions
gem 'mongoid', github: 'mongoid/mongoid'
gem 'bson_ext'

#auth gems
gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'

#figaro for ENV variables
gem 'figaro'

#redis for cacheing and performance
gem 'redis'

#resque for sceduling save jobs and other bg tasks
gem 'resque'
gem 'resque-scheduler'

#whenever for cron jobs in rails syntax
gem 'whenever', require: false

#geocoder for location services
gem 'geocoder'

# AWS Services
gem 'aws-sdk', '~> 2'

#enums for constants
gem 'enumerize'

#koala for facebook graph api
gem "koala", "~> 2.2"

#for pagination
gem 'kaminari'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  #Hirb for easy viewing in console
  gem 'hirb'
end


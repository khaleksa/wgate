source 'https://rubygems.org'

gem 'rails', '4.2.1'

gem 'pg'

gem 'seed-fu', git: 'https://github.com/mbleigh/seed-fu'
gem 'seedbank'

gem 'haml-rails'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'

gem 'sidekiq'
gem 'sinatra', :require => nil # sidekiq admin

gem 'aasm'
gem 'httparty'
gem 'activerecord-import'

group :development, :test do
  gem 'pry'
  gem 'pry-doc'
  gem 'pry-rails'
  gem 'pry-byebug'

  gem 'rspec',       '~> 3.0.0'
  gem 'rspec-rails', '~> 3.0.0'

  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'factory_girl_rspec'

  gem 'webmock'
end

group :test do
  gem 'shoulda-matchers'

  gem 'timecop', :require => false

  gem 'httpi', :git => 'https://github.com/savonrb/httpi.git'
  gem 'savon', '~> 2.0'
end

group :development do
  gem 'capistrano', '~> 3.1.0'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rails', '~> 1.1.1'
  gem 'capistrano-rvm', github: "capistrano/rvm"
end

group :production do
  gem 'unicorn'
end

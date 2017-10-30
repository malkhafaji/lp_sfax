source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
gem "execjs"
gem 'therubyracer', platforms: :ruby
gem 'ci_reporter'
gem 'faraday'
gem 'rails', '~> 5.0.1'
gem 'pg'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'httparty', '~> 0.14.0'
gem 'figaro'
gem 'haml', '~> 4.0.5'
gem 'rubyzip'
gem 'sidekiq', '~> 5.0.4'
gem 'redis-namespace'
gem 'chartkick'
gem 'groupdate'
gem 'omniauth-azure-oauth2'
gem 'datatables-rails', '~> 1.10.7.0'
gem 'will_paginate', '~> 3.1', '>= 3.1.6'
gem 'exception_notification'
gem 'highline'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 3.5'
end

group :development do
  gem 'capistrano', '~> 3.6'
  gem 'capistrano-rails', '~> 1.3'
  gem 'web-console', '>= 3.3.0'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'listen', '~> 3.1', '>= 3.1.5'
  gem 'faker', '~> 1.7', '>= 1.7.3'
  gem 'letter_opener'
  gem 'bullet'
end

group :production, :staging do
  gem 'whenever', '~> 0.9.4'
end
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

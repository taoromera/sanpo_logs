source 'https://rubygems.org'

gem 'rails', '3.2.5'
gem 'jquery-rails'

#For debugging
gem "pry", "~> 0.9.9.6", :require => "pry"

#our web server
gem 'thin'

# postgresql
gem 'pg'

# Ruby support for postgis
gem 'activerecord-postgis-adapter'
gem 'rgeo-geojson'

gem "json"

#To get messages from exceptions in our server
gem 'exception_notification'
gem 'letter_opener', group: :development

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # some trendy techs
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :test do
  gem 'rspec', '=2.10.0'
  gem 'rspec-rails', '=2.10.1'
end

group :development do
  gem 'capistrano', '= 2.12.0'
  gem 'capistrano-ext', '= 1.2.1'
end


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'


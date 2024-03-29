source 'https://rubygems.org'

gem 'rails', ' 3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'


group :development, :test do
  gem 'sqlite3'         # nur für entwicklungs-zwecke
  gem 'mysql2'          # for rails
  gem "mysql",  "2.8.1"  # only for rubyrep
  gem 'rubyrep', '1.1.2d', :git => 'https://github.com/rostchri/rubyrep.git', :branch => 'develop' # used to fix a bug in rubyrep when used in rails 3 environments
end

group :production do
  # postgres-database
  # gem 'pg'
  # mysql-database
  gem 'mysql2'
end

gem "rack-reverse-proxy", :require => "rack/reverse_proxy", :git => 'https://github.com/rostchri/rack-reverse-proxy.git', :branch => 'post-process-body'

gem 'authlogic'
gem "inherited_resources"
gem 'kaminari'
gem "haml"
gem "has_scope"
gem "responders"
gem 'mechanize'
gem 'feedzirra'
gem 'diffy'

# paperclip with amazon s3
gem "paperclip", "~> 3.0"
gem 'aws-sdk', '~> 1.3.4'

gem 'formtastic', :git => 'git://github.com/justinfrench/formtastic.git', :branch => '2.1-stable', :require => 'formtastic'
gem 'formtastic-bootstrap', :git => 'git://github.com/cgunther/formtastic-bootstrap.git', :branch => 'bootstrap2-rails3-2-formtastic-2-1', :require => 'formtastic-bootstrap'

# bootstrap
#gem 'bootstrap-sass', git: 'https://github.com/thomas-mcdonald/bootstrap-sass', branch: '2.1-wip'
# kickstrap
#gem 'kickstrap_rails', :git => 'https://github.com/tonic20/kickstrap_rails.git'

gem 'tablegrid', :git => 'https://github.com/rostchri/tablegrid.git'
gem 'railstrap', :git => 'https://github.com/rostchri/railstrap.git', :branch => 'develop'
#gem 'tablegrid', :path => '~/bo/programming/github/tablegrid'
#gem 'railstrap', :path => '~/bo/programming/github/railstrap'

# kickstrap - really no longer needed?
gem 'less-rails' # kickstrap_rails needs this. deps are missing in kickstrap_rails. see environment.rb too
gem 'therubyracer', :platform => :ruby


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'jquery-rails'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-ui-rails'
end


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

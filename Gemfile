# because rails is precious about vendor/gems
bundle_path "vendor/bundler_gems"
# this line forces us to use only the bundled gems - making it safer to
# deploy knowing that we won't accidentally assume a gem in existence
# somewhere in the wider world.
# disable_system_gems

gem 'rails', '2.3.4'

# gem "calendar_date_select"
# gem "populator"
gem "faker"
gem "sqlite3-ruby", :require_as => 'sqlite3'
gem 'ruby-debug', :except => 'production' 

only :testing do
  gem "redgreen"
  gem "rspec"
  gem "rspec-rails"
end

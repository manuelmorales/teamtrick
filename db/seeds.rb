require 'active_record/fixtures'

puts "Loading roles..."
Fixtures.create_fixtures("#{Rails.root}/spec/fixtures", "roles")

namespace :teamtrick do
  desc "This creates the configuration file if it doens't exist yet"
  task :configure do
    origin = 'config/database.original'
    target = 'config/database.yml'
    unless File.exists?(target)
      FileUtils.cp(origin, target) 
      puts "Created #{target}"
    end
  end

  desc "This creates and sets up the database from scratch"
  task :install => [:configure, :environment, 'db:migrate', 'db:seed', 'db:generate_sample_project']

  desc "This will unpack all gems including Rails"
  task :unpack do
    # Doing it this way because  gems:unpack and rails:freeze:gems don't get
    # along if put as a dependency of the same task.
    system 'script/unpack'
  end

  desc 'This will set RAILS_ENV to "production"'
  task :force_production_environment do
    RAILS_ENV = 'production'
  end

  desc "This will unpack gems and configure the application"
  task :bundle => [:clean, :force_production_environment, :install, :unpack]

  desc "This will delete your database and all files created by TeamTrick. Very destructive!!!"
  task :clean do
    file_list = File.read(".gitignore").split("\n")
    file_list << "vendor/gems"
    file_list << "vendor/rails"

    Dir.glob(file_list).each do |f|
      puts "Deleting " + f
      FileUtils.rm_r f
    end
  end

  # desc "This will delete everything and create a zip file with a just configured app for Linux"
  # task :bundle_linux => [:clean, :install, :unpack] do
  #   system 'zip -r ../teamtrick-linux.zip ../teamtrick'
  # end

  # desc "This will delete everything and create a zip file with a just configured app for Windows"
  # task :bundle_windows => [:clean, :install, :unpack] do
  #   FileUtils.rm_r 'vendor/gems/sqlite3-ruby-1.2.5'
  #   FileUtils.cp_r 'vendor/native/sqlite3-ruby-1.2.5-x86-mingw32', 'vendor/gems/sqlite3-ruby-1.2.5'
  #   system 'zip -r ../teamtrick-windows.zip ../teamtrick'
  # end
end

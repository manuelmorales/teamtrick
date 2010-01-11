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
  task :install => [:configure, :environment, 'db:migrate', 'db:seed', 'db:generate_sample_project'] do
    puts "TeamTrick successfully installed"
  end

  desc "This will unpack all gems including Rails"
  task :unpack do
    # Doing it this way because  gems:unpack and rails:freeze:gems don't get
    # along if put as a dependency of the same task.
    system 'script/unpack'
  end

  desc 'This will set RAILS_ENV to "production"'
  task :force_production_environment do
    puts "Forcing production environment"
    RAILS_ENV = 'production'
  end

  desc "This will unpack gems and configure the application"
  task :bundle => [:clean, :force_production_environment, :install, :unpack] do
    @platform = "linux"
    puts "TeamTrick successfully bundled for Linux"
  end

  desc "This will delete your database and all files created by TeamTrick. Very destructive!!!"
  task :clean do
    puts "Completely cleaning TeamTrick"
    file_list = File.read(".gitignore").split("\n")
    file_list << "vendor/gems"
    file_list << "vendor/rails"

    Dir.glob(file_list).each do |f|
      puts "Deleting " + f
      FileUtils.rm_r f
    end
  end

  desc "This will take an already bundled TeamTrick and will make it Windows friendly"
  task :convert_bundle_to_windows do
    @platform = "windows"
    FileUtils.rm_r 'vendor/gems/sqlite3-ruby-1.2.5'
    FileUtils.cp_r 'vendor/native/sqlite3-ruby-1.2.5-x86-mingw32', 'vendor/gems/sqlite3-ruby-1.2.5'
    puts "TeamTrick successfully bundled for Windows"
  end

  desc "This will create a zip file with this application at ../teamtrick-$platform.zip"
  task :zip do
    current_dir = File.basename FileUtils.pwd
    @platform ||= "linux"
    zip_file_name = "teamtrick-#{@platform}.zip"

    FileUtils.cd '..' do
      FileUtils.rm zip_file_name if File.exists? zip_file_name
      system "zip -r #{zip_file_name} #{current_dir} -x \"teamtrick/.git/*\""
      puts "TeamTrick successfully zipped at ../#{zip_file_name}"
    end
  end

  desc "This will bundle and zip the application for both, linux and windows at ../teamtrick-linux.zip and ../teamtrick-windows.zip"
  task :zip_all => [:bundle, :zip, :convert_bundle_to_windows] do
    Rake::Task["teamtrick:zip"].reenable
    Rake::Task["teamtrick:zip"].invoke
  end
end

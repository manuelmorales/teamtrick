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
end

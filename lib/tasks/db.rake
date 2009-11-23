namespace :db do
  desc "This loads all the fixtures but Roles."
  task :load_fixtures => :environment do
    require 'active_record/fixtures'
    Dir.glob("spec/fixtures/*.yml").each do |file|
      base_name = File.basename(file, '.*')

      if base_name == 'roles'
        puts "Skipping #{base_name}, do rake db:seed for that"
      else
        puts "Loading #{base_name}..."
        Fixtures.create_fixtures('spec/fixtures', base_name)
      end
    end
  end

  desc "This drops the db, builds the db and loads all fixtures."
  task :reload_fixtures => [:environment, 'db:reset', 'db:load_fixtures']

  desc "This will create a new project full of sample data"
  task :generate_sample_project => :environment do
    require 'populator'
    require 'faker'

    Project.populate 1 do |p|
      p.name = "Sample Project"
      p.description = 'This is a sample project created just to show TeamTrick\'s features. Most of its data is generated randomly.'

      User.populate 4 do |u|
        u.real_name = Faker::Name.name
        u.login = Faker::Internet.user_name
        u.email = Faker::Internet.email
        u.available_hours_per_week = [35, 40]
        u.admin = false
        u.disabled = true
        u.crypted_password = User.new.random_password
        
        Duty.populate 1 do |c|
          c.user_id = u.id
          c.project_id = p.id
          c.role_id = Role.team_member.id
        end
      end

      n = 0
      Sprint.populate 5 do |sprint|
        sprint.start_date = Date.today - 4*7*(n+1) + 1
        sprint.finish_date = Date.today - 4*7*n
        n += 1
        sprint.estimated_focus_factor = [ 0.6, 0.65, 0.7, 0.8]
        sprint.project_id = p.id

        users = [1, 2, 3, 4]
        Commitment.populate 4 do |commitment|
          commitment.user_id = users.pop
          commitment.sprint_id = sprint.id
          commitment.level = [ 50, 80, 100, 100, 100, 100]
        end

        def generate_description
          Faker::Company.bs.capitalize + " and " + Faker::Company.bs + "."
        end

        # Finished Stories
        importance = 1
        Story.populate 16..20 do |story|
          story.name = Faker::Company.bs.capitalize
          story.description = generate_description
          story.storypoints = [5, 7, 10, 15, 25, 50]
          story.project_id = p.id
          story.importance = importance += 1

          unless n == 1
            Planning.populate 1 do |planning|
              planning.story_id = story.id
              planning.sprint_id = sprint.id
              planning.original_estimation = 32
              planning.created_at = sprint.start_date..sprint.finish_date
            end
          end

          Task.populate 4 do |t|
            t.name = Faker::Company.bs.capitalize
            t.description = generate_description
            t.original_estimation = 8
            t.hours_left = 0
            t.story_id = story.id

            WorkHour.populate 1 do |wh|
              wh.user_id = (1..4).to_a
              wh.task_id = t.id
              wh.date = sprint.start_date..sprint.finish_date
              wh.hours = 7..10
              wh.old_hours_left = 8
            end
          end
        end
      end

      # Stories without tasks
      importance = 20
      Story.populate 5..10 do |story|
        story.name = Faker::Company.catch_phrase
        story.description = generate_description
        story.storypoints = [5, 7, 10, 15, 25, 50]
        story.project_id = p.id
        story.importance = importance += 1
      end

      # Stories with tasks
      importance = 40
      Story.populate 20..30 do |story|
        story.name = Faker::Company.catch_phrase
        story.description = generate_description
        story.storypoints = [5, 7, 10, 15, 25, 50]
        story.project_id = p.id
        story.importance = importance += 1

        Task.populate 2..4 do |t|
          t.name = Faker::Company.catch_phrase
          t.description = generate_description
          t.original_estimation = 8..16
          t.hours_left = t.original_estimation
          t.story_id = story.id
        end
      end
    end
  end

  desc "This will create an Admin user called 'admin' and password 'admin' for development pourposes."
  task :create_admin_user => :environment do
    u = User.create :login => 'admin', 
      :email => 'admin@mail.com', 
      :real_name => 'Admin', 
      :available_hours_per_week => 40, 
      :password => 'admin', 
      :password_confirmation => 'admin'

    u.update_attribute :admin, true
  end

  desc "This will create users called scrum_master and team_member, passwords are the same than logins."
  task :create_development_users => [:environment, :create_admin_user] do
    %w{scrum_master team_member}.each do |name|
      u = User.create :login => name, 
        :email => name + '@mail.com', 
        :real_name => name.capitalize, 
        :available_hours_per_week => 40, 
        :password => name, 
        :password_confirmation => name

      Duty.create :user => u, :project => Project.find_by_name("Sample Project"), :role => Role.send(name)
    end
  end

  desc "This drops the db, builds the db and loads sample data and creates development users."
  task :reload_development_environment => [:environment, 'db:reset', 'db:generate_sample_project', 'db:create_development_users']
end

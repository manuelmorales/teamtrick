namespace :pfc do
  desc "This will create a new project full of sample data"
  task :generate_sample_project => :environment do
    require 'populator'
    require 'faker'

    Project.populate 1 do |p|
      p.name = 'Firmware para Teléfono Móvil'
      p.description = 'Software para el manejo de un nuevo teléfono móvil'
      stories = (YAML.load File.read('db/sample_data/stories.yml')).reverse
      users = (YAML.load File.read('db/sample_data/users.yml')).reverse

      User.populate 6 do |u|
        user = users.shift
        u.real_name = user[:name]
        u.login = user[:user_name]
        u.email = user[:user_name] + "@team-trick.net"
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

      def generate_description
        Faker::Company.bs.capitalize + " and " + Faker::Company.bs + "."
      end

      # Backlog
      importance = 0
      Story.populate 10 do |story|
        s = stories.shift
        stories << s
        story.name = s[:name]
        story.description = s[:description]
        story.storypoints = [5, 7, 10, 15, 25, 50]
        story.project_id = p.id
        story.importance = importance += 1

        tasks = (YAML.load File.read('db/sample_data/tasks.yml'))
        Task.populate 4 do |t|
          task = tasks.shift
          t.name = task[:name]
          t.description = task[:description]
          t.original_estimation = 8..16
          t.hours_left = t.original_estimation
          t.story_id = story.id
        end
      end

      n = 0
      Sprint.populate 3 do |sprint|
        sprint.start_date = Date.today - 4*7*(n)
        sprint.finish_date = Date.today - 4*7*(n - 1) - 1
        n += 1
        sprint.estimated_focus_factor = [ 0.6, 0.65, 0.7, 0.8]
        sprint.project_id = p.id

        users = [1, 2, 3, 4]
        Commitment.populate 4 do |commitment|
          commitment.user_id = users.pop
          commitment.sprint_id = sprint.id
          commitment.level = [ 50, 80, 100, 100, 100, 100]
        end

        # Finished Stories
        importance = 1
        Story.populate 6 do |story|
          s = stories.shift
          stories << s
          story.name = s[:name]
          story.description = s[:description]
          story.storypoints = [5, 7, 10, 15, 25, 50]
          story.project_id = p.id
          story.importance = importance += 1

          unless n == 1
            Planning.populate 1 do |planning|
              planning.story_id = story.id
              planning.sprint_id = sprint.id
              planning.original_estimation = 128
              planning.created_at = sprint.start_date..sprint.finish_date
            end
          end


          tasks = (YAML.load File.read('db/sample_data/tasks.yml'))
          Task.populate 4 do |t|
            task = tasks.shift
            t.name = task[:name]
            t.original_estimation = 32
            t.hours_left = 0
            t.story_id = story.id

            WorkHour.populate 1 do |wh|
              wh.user_id = (1..4).to_a
              wh.task_id = t.id
              wh.date = sprint.start_date..sprint.finish_date
              wh.hours = 29..36
              wh.old_hours_left = 32
            end
          end
        end
      end
    end
  end

  desc "This drops the db, builds the db and loads sample data and creates development users."
  task :reload_db => [:environment, 'db:reset', 'pfc:generate_sample_project', 'db:create_development_users']
end

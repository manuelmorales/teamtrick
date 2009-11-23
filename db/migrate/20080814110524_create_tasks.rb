class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :name
      t.text :description
      t.integer :original_estimation
      t.integer :hours_left
      t.integer :sprint_id
      t.integer :story_id

      t.timestamps
    end

    create_table :tasks_work_hours, :id => false do |t|
      t.integer :task_id, :null => false
      t.integer :work_hour_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
    drop_table :tasks_work_hours
  end
end

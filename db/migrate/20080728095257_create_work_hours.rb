class CreateWorkHours < ActiveRecord::Migration
  def self.up
    create_table :work_hours do |t|
      t.integer :hours
      t.integer :user_id
      t.integer :task_id
      t.integer :old_hours_left
      t.date :date

      t.timestamps
    end
  end

  def self.down
    drop_table :work_hours
  end
end

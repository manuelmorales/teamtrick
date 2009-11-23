class CreateSprints < ActiveRecord::Migration
  def self.up
    create_table :sprints do |t|
      t.date :start_date
      t.date :finish_date
      t.integer :number_of_workdays
      t.string :demo_meeting
      t.string :scrum_meeting
      t.string :retrospective_meeting
      t.float :estimated_focus_factor
      t.text :retrospective_report
      t.integer :project_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sprints
  end
end

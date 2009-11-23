class CreatePlannings < ActiveRecord::Migration
  def self.up
    create_table :plannings do |t|
      t.integer :story_id
      t.integer :sprint_id
      t.integer :original_estimation
      t.boolean :unexpected

      t.timestamps
    end
  end

  def self.down
    drop_table :plannings
  end
end

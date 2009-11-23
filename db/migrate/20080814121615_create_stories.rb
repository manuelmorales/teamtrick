class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
      t.string :name
      t.text :description
      t.integer :storypoints
      t.integer :user_id
      t.integer :project_id
      t.integer :importance

      t.timestamps
    end
  end

  def self.down
    drop_table :stories
  end
end

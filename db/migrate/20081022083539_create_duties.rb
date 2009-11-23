class CreateDuties < ActiveRecord::Migration
  def self.up
    create_table :duties do |t|
      t.integer :user_id, :null => false
      t.integer :project_id, :null => false
      t.integer :role_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :duties
  end
end

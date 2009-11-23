class CreateCommitments < ActiveRecord::Migration
  def self.up
    create_table :commitments do |t|
      t.integer :user_id
      t.integer :sprint_id
      t.float :level

      t.timestamps
    end
  end

  def self.down
    drop_table :commitments
  end
end

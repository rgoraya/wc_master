class AddUserIdToAllTables < ActiveRecord::Migration
  def self.up
	add_column :relationships, :user_id, :integer
	add_column :references, :user_id, :integer
  end

  def self.down
	remove_column :relationships, :user_id
	remove_column :references, :user_id
  end
end

class AddUserIdToReferences < ActiveRecord::Migration
  def self.up
    add_column :references, :user_id, :integer
  end

  def self.down
    remove_column :references, :user_id
  end
end

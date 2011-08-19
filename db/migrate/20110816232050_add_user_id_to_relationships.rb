class AddUserIdToRelationships < ActiveRecord::Migration
  def self.up
    add_column :relationships, :user_id, :integer
  end

  def self.down
    remove_column :relationships, :user_id
  end
end

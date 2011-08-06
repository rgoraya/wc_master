class AddRevertedFromToVersion < ActiveRecord::Migration
  def self.up
    add_column :versions, :reverted_from, :integer
  end

  def self.down
    remove_column :versions, :reverted_from
  end
end

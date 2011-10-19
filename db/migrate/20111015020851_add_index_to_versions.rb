class AddIndexToVersions < ActiveRecord::Migration
  def self.up
		add_index :versions, :whodunnit
		add_index :versions, :event
  end

  def self.down
		remove_index :versions, :column => :whodunnit
		remove_index :versions, :column => :event
  end
end

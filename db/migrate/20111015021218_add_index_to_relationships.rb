class AddIndexToRelationships < ActiveRecord::Migration
  def self.up
		add_index :relationships, :issue_id
		add_index :relationships, :cause_id
  end

  def self.down
		remove_index :relationships, :column => :issue_id
		remove_index :relationships, :column => :cause_id
  end
end

class RemovePermalinkFromIssues < ActiveRecord::Migration
  def self.up
    remove_column :issues, :permalink
  end

  def self.down
    add_column :issues, :permalink, :string
  end
end

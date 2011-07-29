class AddPermalinkToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :permalink, :string
  end

  def self.down
    remove_column :issues, :permalink
  end
end

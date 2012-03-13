class AddRelationshipsCountToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :relationships_count, :integer
    Issue.reset_column_information
      Issue.find(:all).each do |p|
        Issue.update_counters p.id, :relationships_count => p.relationships.length
      end
  end

  def self.down
    remove_column :issues, :relationships_count
  end
end

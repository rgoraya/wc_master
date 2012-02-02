class AddReferencesCountToRelationships < ActiveRecord::Migration
  def self.up
    add_column :relationships, :references_count, :integer, :default => 0
      Relationship.reset_column_information
      Relationship.find(:all).each do |p|
      Relationship.update_counters p.id, :references_count => p.references.length
    end
  end
  def self.down
    remove_column :relationships, :references_count
  end
end

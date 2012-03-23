class RemoveRelationshipsCountFromRelationships < ActiveRecord::Migration
  def self.up
    remove_column :relationships, :relationships_count
  end

  def self.down
    add_column :relationships, :relationships_count, :integer
  end
end

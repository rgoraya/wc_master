class AddRelationshipTypeToRelationships < ActiveRecord::Migration
  def self.up
    add_column :relationships, :relationship_type, :string
  end

  def self.down
    remove_column :relationships, :relationship_type
  end
end

class CreateReferences < ActiveRecord::Migration
  def self.up
    create_table :references do |t|
      t.integer :relationship_id
      t.string :reference_content

      t.timestamps
    end
  end

  def self.down
    drop_table :references
  end
end

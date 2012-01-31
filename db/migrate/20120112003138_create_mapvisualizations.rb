class CreateMapvisualizations < ActiveRecord::Migration
  def self.up
    create_table :mapvisualizations do |t|
      t.string :name
      t.integer :node_count

      t.timestamps
    end
  end

  def self.down
    drop_table :mapvisualizations
  end
end

class CreateSuggestions < ActiveRecord::Migration
  def self.up
    create_table :suggestions do |t|
      t.string :title
      t.string :wiki_url
      t.string :causality
      t.string :status
      t.integer :issue_id

      t.timestamps
    end
  end

  def self.down
    drop_table :suggestions
  end
end

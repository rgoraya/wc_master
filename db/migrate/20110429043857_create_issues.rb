class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.string :title
      t.string :description
      t.string :wiki_url
      t.string :short_url

      t.timestamps
    end
  end

  def self.down
    drop_table :issues
  end
end

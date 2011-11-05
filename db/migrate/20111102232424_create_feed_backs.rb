class CreateFeedBacks < ActiveRecord::Migration
  def self.up
    create_table :feed_backs do |t|
      t.string :subject
      t.string :description
      t.string :email
      t.integer :user_id
      t.integer :category

      t.timestamps
    end
  end

  def self.down
    drop_table :feed_backs
  end
end

class AddReputationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :reputation, :integer, :default=>1
  end

  def self.down
    remove_column :users, :reputation
  end
end

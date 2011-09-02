class RenameMyColumnByHand1 < ActiveRecord::Migration
  def self.up
    rename_column :suggestions, :suggestion_type, :causality
  end

  def self.down
    rename_column :suggestions, :suggestion_type, :causality
  end
end

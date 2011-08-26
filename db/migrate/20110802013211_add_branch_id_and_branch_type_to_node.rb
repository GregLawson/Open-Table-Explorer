class AddBranchIdAndBranchTypeToNode < ActiveRecord::Migration
  def self.up
    add_column :nodes, :branch_id, :integer
    add_column :nodes, :branch_type, :string
  end

  def self.down
    remove_column :nodes, :branch_type
    remove_column :nodes, :branch_id
  end
end

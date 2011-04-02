class AddParentNodeToWiredLocations < ActiveRecord::Migration
  def self.up
    add_column :wired_locations, :parent_node, :integer
  end

  def self.down
    remove_column :wired_locations, :parent_node
  end
end

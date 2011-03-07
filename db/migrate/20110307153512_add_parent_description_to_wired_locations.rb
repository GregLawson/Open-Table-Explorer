class AddParentDescriptionToWiredLocations < ActiveRecord::Migration
  def self.up
    add_column :wired_locations, :parent_description, :string
  end

  def self.down
    remove_column :wired_locations, :parent_description
  end
end

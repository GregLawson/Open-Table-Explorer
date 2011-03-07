class AddUserInterfaceToWiredLocations < ActiveRecord::Migration
  def self.up
    add_column :wired_locations, :user_interface, :string
  end

  def self.down
    remove_column :wired_locations, :user_interface
  end
end

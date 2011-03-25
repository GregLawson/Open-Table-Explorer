class AddAccountIdToTrabsfer < ActiveRecord::Migration
  def self.up
    add_column :transfers, :account_id, :integer
  end

  def self.down
    remove_column :transfers, :account_id
  end
end

class AddOtsLineToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :open_tax_solver_line, :string
  end

  def self.down
    remove_column :accounts, :open_tax_solver_line
  end
end

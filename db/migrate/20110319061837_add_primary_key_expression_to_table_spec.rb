class AddPrimaryKeyExpressionToTableSpec < ActiveRecord::Migration
  def self.up
    add_column :table_specs, :primary_key_expression, :string
  end

  def self.down
    remove_column :table_specs, :primary_key_expression
  end
end

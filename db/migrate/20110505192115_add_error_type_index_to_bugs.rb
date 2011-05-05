class AddErrorTypeIndexToBugs < ActiveRecord::Migration
  def self.up
    add_column :bugs, :error_type_id, :integer
    add_index :bugs,[:error,:context,:url], :unique => true
  end

  def self.down
    remove_column :bugs, :error_type_id
    remove_index :bugs,:column => [:error,:context,:url]
  end
end

class GenericTypeToInteger < ActiveRecord::Migration
  def self.up
	change_table :example_Types do |t|
		t.remove :generic_type_id
		t.integer :generic_type_id

	end #change_table
  end

  def self.down
	change_table :example_Types do |t|
		t.remove :generic_type_id
		t.string :generic_type_id
	end #change_table
  end
end

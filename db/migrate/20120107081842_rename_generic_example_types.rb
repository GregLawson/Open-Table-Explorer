class RenameGenericExampleTypes < ActiveRecord::Migration
  def self.up
	change_table :generic_types do |t|
		t.rename :search_sequence, :generalize_id
	end #change_table
	change_table :example_Types do |t|
		t.rename :import_class, :generic_type_id
	end #change_table
  end

  def self.down
	change_table :generic_types do |t|
		t.rename :generalize_id,:search_sequence
	end #change_table
	change_table :example_Types do |t|
		t.rename :generic_type_id,:import_class
	end #change_table
  end
end

class RenameAcqInterfaceIdToAcqStreamIdInAcquisitions < ActiveRecord::Migration
  def self.up
	change_table :acquisitions do |t|
		t.rename :acquisition_stream_id, :acquisition_stream_spec_id
	end #change_table
  end

  def self.down
	change_table :acquisitions do |t|
		t.rename :acquisition_stream_spec_id,:acquisition_stream_id
	end #change_table
  end
end

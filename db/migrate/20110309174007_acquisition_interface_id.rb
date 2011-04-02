class AcquisitionInterfaceId < ActiveRecord::Migration
  def self.up
	change_table :acquisition_stream_specs do |t|
		t.rename :acquisitioninterface_id,:acquisition_interface_id
	end #change table
  end

  def self.down
        change_table :acquisition_stream_specs do |t|
                t.rename :acquisition_interface_id, :AcquisitionInterface_Id
        end #change table
  end
end

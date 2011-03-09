class DowncaseAcquisitionInterfaceId < ActiveRecord::Migration
  def self.up
	change_table :acquisition_stream_specs do |t|
		t.rename :AcquisitionInterface_Id, :acquisitioninterface_id
	end #change table
  end

  def self.down
        change_table :acquisition_stream_specs do |t|
                t.rename :acquisitioninterface_Id, :AcquisitionInterface_Id
        end #change table
  end
end

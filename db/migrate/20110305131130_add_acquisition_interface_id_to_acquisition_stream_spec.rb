class AddAcquisitionInterfaceIdToAcquisitionStreamSpec < ActiveRecord::Migration
  def self.up
    add_column :acquisition_stream_specs, :AcquisitionInterface_Id, :integer
  end

  def self.down
    remove_column :acquisition_stream_specs, :AcquisitionInterface_Id
  end
end

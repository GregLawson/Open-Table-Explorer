class Acquisition < ActiveRecord::Base
has_one :acquisition_stream_spec
include Generic_Table
def asociatedAcquisitionStreamSpec
	acquisition_stream_spec=AcquisitionStreamSpec.find_by_id(self[:acquisition_stream_spec_id])
end #def
def acquire(acquisition_stream_spec_id)
	@previousAcq=self[:acquisition_data] # change detection
	self[:acquisition_stream_spec_id]=acquisition_stream_spec_id
	acquisition_stream_spec=asociatedAcquisitionStreamSpec
	self[:acquisition_data]=`#{acquisition_stream_spec.schemelessUrl} 2>&1`
	if $?==0 then
		self[:error]=nil
	else
		self[:error]=self[:acquisition_data]
		self[:acquisition_data]=nil
	end
	return self
rescue Exception => e
 	self[:error]= "Exception: " + e.inspect + "couldn't acquire data from #{url}"
	return self
else
	self[:error]= "Not subclass of Exception: " + "couldn't acquire data from #{url}"
	return self
end #def
def acquisitionDuplicated?(acquisitionData=self[:acquisition_data])
	return @previousAcq==acquisitionData
end #def
def acquisitionUpdated?(acquisitionData=self[:acquisition_data])
	if	acquisitionData.nil?  || acquisitionData.empty? then
		acquisition_updated= false
	elsif @previousAcq.nil? || @previousAcq.empty? then
		acquisition_updated= true
	else
		acquisition_updated= @previousAcq!=acquisitionData
	end
	self[:acquisition_updated]=acquisition_updated
	return acquisition_updated
end #def

end

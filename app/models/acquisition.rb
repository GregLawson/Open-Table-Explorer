class Acquisition < ActiveRecord::Base
has_one :acquisition_stream_spec
include Generic_Table
def asociatedAcquisitionStreamSpec
	acquisition_stream_spec=AcquisitionStreamSpec.find_by_id(self[:acquisition_stream_spec_id])
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
def display
	ret='display: '
	if error then
		ret='<EM>'+error+'</EM>'
		if acquisition_data then
			ret+='<P>'+acquisition_data+'</P>'			
		else
		end #if
	else
		if acquisition_data then
			ret='<P>'+acquisition_data.truncate(200)+'</P>'			
		else
			ret='<EM>There are unexpectedly neither acquisition data nor any errors.</EM>'
		end #if
	end #if
return ret
end #def
end

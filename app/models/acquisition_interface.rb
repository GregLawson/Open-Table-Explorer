###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class AcquisitionInterface < RubyInterface
has_many :acquisition_stream_specs
include Generic_Table
#include Generic_Acquisition 
attr_reader :interaction
# functons of class only
def logical_primary_key
	return :acquisition_name
end #def
# functions of ActiveRecord  instances
def scheme
	if self[:name].nil? then
		return ''
	else
		return self[:name].downcase
	end #if
end #def
def delta(stream)
	@previousAcq=@interaction # change detection
	@interaction=Acquisition.new # reinitialize
	@stream=stream
	@interaction.acquisition_stream_spec=stream
	@interaction.acquisition_stream_spec_id=stream.id
end #def
		acquireBody="if $?==0 then\n"
		acquireBody+="	@interaction.error=nil\n"
		acquireBody+="else\n"
		acquireBody+="	@interaction.error=@interaction.acquisition_data\n"
		acquireBody+="	@interaction.acquisition_data=nil\n"
		acquireBody+="end\n"
@@Default_Return_Code=acquireBody

# functions parameterized by a acquisition_stream_spec and adding instance detail
def acquire(stream)
	delta(stream)
	before_acquire=@interaction.clone # save acquisition_data and error before new acquisition.
	interface_method
	if before_acquire==@interaction then
		puts 'Nothing was acquired and no error was set'
		@interaction.error=['Nothing was acquired and no error was set']
	end #if
	error_return
	rescue  StandardError => exception_raised
		rescue_method
	else
		@interaction[:error]= "Not subclass of StandardError: " + "couldn't acquire data from #{url}"
	ensure
		@interaction.save
		return @interaction
end #def
end # class

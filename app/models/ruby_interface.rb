###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class RubyInterface < ActiveRecord::Base
include Generic_Table
# functons of class only
# functions of ActiveRecord  instances
def setup
	codeBody
end #def
def delta(stream)
	@previousAcq=@acquisition # change detection
	@acquisition=Acquisition.new # reinitialize
	@stream=stream
	@acquisition.acquisition_stream_spec=stream
	@acquisition.acquisition_stream_spec_id=stream.id
end #def
def eval_method(name,code)
	method_def= "def #{name}\n#{code}\nend\n"
	return instance_eval(method_def)
end #def
		acquireBody="if $?==0 then\n"
		acquireBody+="	@acquisition.error=nil\n"
		acquireBody+="else\n"
		acquireBody+="	@acquisition.error=@acquisition.acquisition_data\n"
		acquireBody+="	@acquisition.acquisition_data=nil\n"
		acquireBody+="end\n"
@@Default_Return_Code=acquireBody
		acquireBody="rescue StandardError => exception_raised\n"
#		acquireBody+="@acquisition.error= 'Error: ' + exception_raised.inspect + 'could not get data from '+stream.url\n"
@@Default_Rescue_Code=acquireBody

def codeBody
	if library.nil? then
		eval_method('acquire_method',acquire_data)
	else
		eval_method('acquire_method',"require '#{library}'\n#{acquire_data}")
	end # if
	
	if return_error_code.nil? then
		eval_method('error_return',@Default_Return_Code)
	else
		eval_method('error_return',return_error_code)
	end #if
	if rescue_code.nil? then
		eval_method('rescue_method',@@Default_Rescue_Code)
	else
		eval_method('rescue_method',"rescue #{rescue_code}\n")
	end
end #def
# functions parameterized by a acquisition_stream_spec and adding instance detail
def acquire(stream)
	delta(stream)
	before_acquire=@acquisition
	acquire_method
	if before_acquire!=@acquisition then
		puts 'Nothing was acquired and no error was set'
		@acquisition.error=['Nothing was acquired and no error was set']
	end #if
	error_return
	rescue  StandardError => exception_raised
		rescue_method
	else
		@acquisition[:error]= "Not subclass of StandardError: " + "couldn't acquire data from #{url}"
	ensure
		@acquisition.save
		return @acquisition
end #def
end # class

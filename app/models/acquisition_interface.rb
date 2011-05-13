###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
module Generic_Table
def Generic_Table.rubyClassName(model_class_name)
	model_class_name=model_class_name[0,1].upcase+model_class_name[1,model_class_name.length-1] # ruby class names are constants and must start with a capital letter.
	# remainng case is unchanged to allow camel casing to separate words for model names.
	return model_class_name
end #def
def Generic_Table.classReference(model_class_name,code_body=nil)
	rubyClassName=Generic_Table.rubyClassName(model_class_name)
	model_class_eval=eval("#{classDefiniton(Generic_Table.rubyClassName(model_class_name),code_body)}\n#{rubyClassName}")
	return model_class_eval
end #def
end #module
module Generic_Acquisition
end #module
class AcquisitionInterface < ActiveRecord::Base
has_many :acquisition_stream_specs
include Generic_Table
#include Generic_Acquisition 
attr_reader :objReference
after_initialize :setup
# functons of class only
def logical_primary_key
	return :acquisition_name
end #def
# functions of ActiveRecord  instances
def acquisition_class_name
	return "#{self[:name]}_Acquisition"
end # def
def scheme
	if self[:name].nil? then
		return ''
	else
		return self[:name].downcase
	end #if
end #def
def classDefinition
	return "class #{Generic_Table.rubyClassName(acquisition_class_name)}  \ninclude Generic_Table\n#{codeBody}\nend"
end #def
def classReference
	ruby_class_name=Generic_Table.rubyClassName(acquisition_class_name)
	model_class_eval=eval("#{classDefinition}\n#{ruby_class_name}")
	return model_class_eval
end #def
def setup
	@classDefnition=classDefinition
	@classReference=classReference
	@objReference=@classReference.new
end #def
def delta(stream)
	@previousAcq=@acquisition # change detection
	@acquisition=Acquisition.new # reinitialize
	@stream=stream
end #def
def eval_method(name,code)
	method_def= "def #{name}\n#{code}\nend\n"
	return instance_eval(method_def)
end #def
def codeBody
	if library.nil? then
		ret=''
	else
		ret="require '#{library}'\n"
	end # if
	#~ acquireBody="@previousAcq=@acquisition\n" # change detection
	#~ acquireBody+="@acquisition=Acquisitions.new\n" # reinitialize
	#~ acquireBody+="@uri=URI.parse(URI.escape(@stream.url))\n"
	acquireBody="delta(stream)\n"
	acquireBody+="#{acquire_data}\n"
	
	if return_error_code.nil? then
		 acquireBody+="if $?==0 then\n"
		acquireBody+="	@acquisition.error=nil\n"
		acquireBody+="else\n"
		acquireBody+="	@acquisition.error=@acquisition.acquisition_data\n"
		acquireBody+="	@acquisition.acquisition_data=nil\n"
		acquireBody+="end\n"
	else
		acquireBody+="#{return_error_code}\n"
	end #if
	if rescue_code.nil? then
		acquireBody+="rescue StandardError => exception_raised\n"
#		acquireBody+="self[:error]= 'Error: ' + exception_raised.inspect + 'could not get data from '+stream.url\n"
	else
		acquireBody+="rescue #{rescue_code}\n"
	end
	acquireBody+="return self\n"
	ret+= "def acquire(stream)\n#{acquireBody}\nend\n"
	return ret
end #def
# functions parameterized by a acquisition_stream_spec and adding instance detail
def acquire(stream)
	@objReference.acquire(stream)
		return @acquisition
end #def
end # class

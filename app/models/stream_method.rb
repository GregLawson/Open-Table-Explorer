###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class StreamMethod  < ActiveRecord::Base # like a method def
include Generic_Table
has_many :stream_method_calls
has_many :stream_method_arguments
belongs_to :stream_pattern
has_many :urls
after_initialize :compile_code
# functions of ActiveRecord  instances
def eval_method(name,code)
	if code.nil? || code.empty? then
		rows=0
		cols=0
	else
		code_lines=code.split("\n")
		rows=code_lines.size
		cols=code_lines.map {|l|l.length}.max
	end #if
	
	instance_eval("def #{name}_rows\n#{rows}\nend\n")
	instance_eval("def #{name}_cols\n#{cols}\nend\n")
	method_def= "def #{name}_method\n#{code}\nend\n"
	return instance_eval(method_def)
rescue  SyntaxError => exception_raised
	errors.add(name, 'SyntaxError: ' + exception_raised.inspect, options = {}) 
	return nil
#~ else
	#~ errors.add(name, "Not subclass of SyntaxError: " + "couldn't compile string #{method_def} in context of a ruby_class object.")

end #def
@@Default_Return_Code=''
		acquireBody="rescue StandardError => exception_raised\n"
#		acquireBody+="@interaction.error= 'Error: ' + exception_raised.inspect + 'could not get data from '+stream.url\n"
@@Default_Rescue_Code=acquireBody
def compile_code
	if library.nil? then
		eval_method('interface_code',interface_code)
	else
		eval_method('interface_code',"require '#{library}'\n#{interface_code}")
	end # if
	
	if return_code.nil? then
		eval_method('return_code',@@Default_Return_Code)
	else
		eval_method('return_code',return_code)
	end #if
	if rescue_code.nil? then
		eval_method('rescue_code',@@Default_Rescue_Code)
	else
		eval_method('rescue_code',"rescue #{rescue_code}\n")
	end
end #def
def fire
	interface_code_method
#	if before_acquire==@interaction then
#		@interaction.errors.add(:error,'Nothing was acquired and no error was set')
#	end #if
	return_code_method
	rescue  StandardError => exception_raised
		rescue_code_method
	else
		self.errors.add("Not subclass of StandardError: " + "couldn't acquire data from #{url}")
	ensure
		self[:error]=errors.full_messages
		return self
end #def
end #class

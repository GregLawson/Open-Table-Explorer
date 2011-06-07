###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
module Generic_Table
def Generic_Table.syntax_error(code)
	method_def= "def syntax_check_temp_method\n#{code}\nend\n"
	instance_eval(method_def)
	return nil
rescue  SyntaxError => exception_raised
	return exception_raised.to_s
end #def
def Generic_Table.short_error_message(code)
	error_message= Generic_Table.syntax_error(code)
	if error_message.nil? then
		return nil
	else
		return error_message.sub(%r{^\(eval\):\d+:in `syntax_error': compile error},'').gsub(%r{\(eval\):\d+: syntax error, },'').gsub(%r{\(eval\):\d+: },'')
	end #if
end #def
def Generic_Table.no_syntax_error?(code)
	method_def= "def syntax_check_temp_method\n#{code}\nend\n"
	instance_eval(method_def)
	return true
rescue  SyntaxError => exception_raised
	return false
end #def
end #module
class RubyInterface < ActiveRecord::Base
has_many :acquisition_stream_specs
include Generic_Table
attr_reader :interaction
after_initialize :compile_code
# functons of class only
# functions of ActiveRecord  instances
def delta(stream)
	@interaction=Acquisition.new # reinitialize
end #def
def partition(code,passMask,failMask)
	lines=code.split("\n")
	testLine=testLine+1
	testMask=passMask<<testLine
	if no_syntax_error?(lines.select(testMask).join("\n")) then
		passMask=testMask
	else
		failMask=failMask<<testLine
	end #if

end #def
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
# functions parameterized by a acquisition_stream_spec and adding instance detail
def acquire(stream)
	interface_code_method
	if before_acquire==@interaction then
		@interaction.errors.add(:error,'Nothing was acquired and no error was set')
	end #if
	return_code_method
	rescue  StandardError => exception_raised
		rescue_code_method
	else
		@interaction.errors.add("Not subclass of StandardError: " + "couldn't acquire data from #{url}")
	ensure
		@interaction[:error]=errors.full_messages
		return @interaction
end #def
end # class

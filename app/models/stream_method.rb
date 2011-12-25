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
#after_initialize :compile_code!
# functions of ActiveRecord  instances
def initialize(hash=nil)
	super(hash)
end #initialize
def gui_name(name)
	return "@#{name}"
end #gui_name
def instance_name_reference(name)
	return "self[:#{name}]"
end #gui_name
def default_method
	rhs=case input_stream_names.size
	when 0 
		Math::random
	when 1
		gui_name(input_stream_names[0])
	else
		input_stream_names.map{|n| gui_name(n)}.join(',')
	end #case
	lhs=case output_stream_names.size
	when 0 
		Math::random
	when 1
		gui_name(output_stream_names[0])
	else
		output_stream_names.map{|n| gui_name(n)}.join(',')
		'['+output_stream_names.join(',')+']'
	end #case
	
	return lhs+'='+rhs
end #default_method
# Allow external setting of instance variables
def map_io(code)
	input_stream_names.each do |name|
		code=code.gsub(gui_name(name), instance_name_reference(name))
#		code=code+":input(#{gui_name(name)}, #{instance_name_reference(name)})"
	end #each
	output_stream_names.each do |name|
		code=code.gsub(gui_name(name), instance_name_reference(name))
#		code=code+":output(#{gui_name(name)}, #{instance_name_reference(name)})"
	end #each
	return code
end #map_io
# create a instance (singleton) method with the supplied code.
# the methods have no arguments and communicate through instance variables.
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
	method_def= "def #{name}_method\n#{map_io(code)}\nend\n"
	return instance_eval(method_def)
rescue  SyntaxError => exception_raised
	self[:errorz]=self[:errorz].add(name, 'SyntaxError: ' + exception_raised.inspect, options = {}) 
	return nil
#~ else
	#~ self[:errorz]=self[:errorz].add(name, "Not subclass of SyntaxError: " + "couldn't compile string #{method_def} in context of a ruby_class object.")

end #eval_method
@@Default_Return_Code=''
		acquireBody="rescue StandardError => exception_raised\n"
		acquireBody+="self[:errorz]=self[:errorz].add(:error,'Error: ' + exception_raised.inspect + 'could not get data from '+uri.inspect)"
@@Default_Rescue_Code=acquireBody
def compile_code!
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
end #compile_code
def input_stream_names
	if stream_pattern.nil? then
		return [] # pattern undefined
	else
		stream_pattern_arguments=stream_pattern.stream_pattern_arguments
		stream_inputs=stream_pattern_arguments.select{|a| a.direction=='Input'}
		return stream_inputs.map{|a| a.name.downcase}
	end #if
end #input_stream_names
def output_stream_names
	if stream_pattern.nil? then
		return [] # pattern undefined
	else
		stream_pattern_arguments=stream_pattern.stream_pattern_arguments
		stream_outputs=stream_pattern_arguments.select{|a| a.direction=='Output'}
		return stream_outputs.map{|a| a.name.downcase}
	end #if
end #output_stream_names
def fire!
	self[:errorz]=[] if self[:errorz].nil?
	interface_code_method
	outputs=output_stream_names.select? do |name|
		!self[name.to_sym].nil?
	end #each
	if outputs==[] then
		self[:errorz]=self[:errorz].add(:error,'Nothing was acquired and no error was set')
	else
		self[:errorz]=self[:errorz].add(:error,"output=#{outputs.inspect}")

	end #if
	return_code_method
	rescue  StandardError => exception_raised
		puts "exception_raised=#{exception_raised.inspect}"
		self[:error2]=exception_raised.inspect
		self[:errorz]=self[:errorz].add(exception_raised.inspect)
		rescue_code_method
	else
		self.self[:errorz]=self[:errorz].add("Not subclass of StandardError: " + "couldn't acquire data from #{url}")
	ensure
		self[:errorz]=self[:errorz]+errors.full_messages
		return self
end #fire
end #class

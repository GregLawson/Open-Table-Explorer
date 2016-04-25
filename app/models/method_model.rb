###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
#require_relative '../../app/models/no_db.rb'
class Method # monkey patch

def default_arguments?
	if arity < 0 then
		true
	else
		false
	end # if


end # default_arguments
def required_arguments

	if default_arguments? then
		-(arity+1)
	else
		arity
	end # if
end # required_arguments
end # Method
class MethodModel  #<ActiveRecord::Base
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
end # DefinitionalConstants
include DefinitionalConstants
module ClassMethods
#include DefinitionalConstants
def init_path(m,owner=nil,scope=nil)
	if !m.nil? && owner.nil? && scope.nil? then # only one argument (method)
		theMethod=m
		init_path = [:object_space_method]
		if theMethod.respond_to?(:source_location)
			init_path << :source_location
		else
			init_path << :not_source_location
		end #if
		if theMethod.respond_to?(:parameters)
			init_path << :parameters
		end #if
	else #3 arguments
		init_path = [:init]

		if scope.to_sym==:class then
			init_path << :class
		else
			theMethod=MethodModel.method_query(m, owner)
		end #if
		if !theMethod.nil? then
			init_path << :theMethod_not_nil
			if theMethod.respond_to?(:source_location)
				init_path << :source_location
			else
				init_path << :not_source_location
			end #if
			if theMethod.respond_to?(:parameters)
				init_path << :parameters
			end #if
		else
			init_path << :theMethod_nil
		end #if
	end #if
	begin
		attributes[:protected]=protected_method_defined?(m)
		attributes[:private]=private_method_defined?(m)
		init_path << :protected
	rescue StandardError => exc
		init_path << :rescue_protected
	end #if
	if m.to_s[/[a-zA-Z0-9_]+/,0]==m.to_s then
		init_path << :alphanumeric
	else
		init_path << :not_alphanumeric
	end #if
init_path
end # init_path
def method_query(m, owner)
	ObjectSpace.each_object(owner) do |object| 
		if object.respond_to?(m.to_sym) then
		begin
			theMethod = object.method(m.to_sym)
			return theMethod
		rescue ArgumentError, NameError => exc
			puts "exc=#{exc}, object=#{object.inspect}"
		end #begin
		end #if
	end #each_object
	return nil #no object found, new has side effects
end # method_query
def constantized
	@@CONSTANTIZED||=Module.constants.map do |c|
		begin
			c=c.constantize
		rescue
			 puts "constant #{c.inspect} fails constanization"
			 nil
		 end #begin
	end #map
end #constantized
end # ClassMethods
extend ClassMethods
  include Virtus.value_object
  values do
 	attribute :name, Symbol
	attribute :owner, Object
	attribute :scope, Class, :default => nil
	attribute :new_from_method, Method, :default => nil
end # values
module Constructors # such as alternative new methods
include DefinitionalConstants
def new_from_method(method_object)
	MethodModel.new(name: method_object.name, owner: method_object.owner, scope: method_object.owner.class, new_from_method: method_object)
end # new_from_method
end # Constructors
extend Constructors
def inspect
	@name.inspect + ' sends to ' + @owner.inspect + ', scope= ' + @scope.inspect + ' ' + @new_from_method.inspect + "\n"
end # inspect
#include NoDB
def theMethod
	if @scope.to_sym==:class then
		@owner.method(@name.to_sym)
	else # look it up! Why? Beause can't create fully? Existence check?
		MethodModel.method_query(@name.to_sym, @owner)
	end #if
end # theMethod
def source_location
		if theMethod.respond_to?(:source_location)
			theMethod.source_location
		else
			nil
		end #if
end # source_location
def parameters
	if theMethod.respond_to?(:parameters)
		theMethod.parameters
	else
	 	nil
	end #if

end # parameters
def find_example?(unit_class)
	examples = Example.find_by_class(unit_class, unit_class)
	if examples.empty? then
		nil
	else
		examples.first
	end # if
end # find_example?
def make_executable_object(file_argument)
	if @unit_class.included_modules.include?(Virtus::InstanceMethods) then
		@unit_class.new(executable: TestExecutable.new(executable_file: file_argument))
	else
		@unit_class.new(TestExecutable.new_from_path(file_argument))
	end # if
end # make_executable_object
def executable_object(file_argument = nil)
	example = find_example?
	if file_argument.nil? then
		if example.nil? then # default
			if number_of_arguments == 0 then
				make_executable_object($0) # script file
			else
				make_executable_object(@argv[1])
			end # if
		else
			example.value
		end # if
	else
		make_executable_object(file_argument)
	end # if
	
end # executable_object
def executable_method?(method_name, argument = nil)
	executable_object = executable_object(argument)
	ret = if executable_object.respond_to?(method_name) then
		method = executable_object.method(method_name)
	else
		nil
	end # if
end # executable_method?
def method_exception_string(method_name)
		message = "#{method_name.to_s} is not an instance method of #{executable_object.class.inspect}"
		message += "\n candidate_commands = "
		message += candidate_commands_strings.join("\n")
#		message += "\n\n executable_object.class.instance_methods = " + executable_object.class.instance_methods(false).inspect
end # method_exception_string
def arity(method_name)
	executable_method = executable_method?(method_name)
	ret = if executable_method.nil? then
		message = "#{method_name} is not an instance method of #{executable_object.class.inspect}"
		message = candidate_commands_strings.join("\n")
#		message += "\n candidate_commands = " + candidate_commands.inspect
#		message += "\n\n executable_object.class.instance_methods = " + executable_object.class.instance_methods(false).inspect
		fail Exception.new(message)
	else
		executable_method.arity
	end # if
end # arity
def default_arguments?(method_name)
	if arity(method_name) < 0 then
		true
	else
		false
	end # if


end # default_arguments
def required_arguments(method_name)

	method_arity = arity(method_name)
	if default_arguments?(method_name) then
		-(method_arity+1)
	else
		method_arity
	end # if
end # required_arguments
module Examples
	class EmptyClass
	end
end # Examples
end # MethodModel

class Example
def require1(required_arg, default_arg = nil)
end # require1
def require2(required_arg, required_arg2)
end # require2
def require3(required_arg, required_arg2, required_arg3)
end # require3
def all_default(default_arg = nil)
end # all_default
module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
#include DefinitionalConstants
Method_arity = MethodModel.new(name: :arity, owner: Method, scope: Class)
Method_require1 = MethodModel.new(name: :require1, owner: Example, scope: Class)
Method_require2 = MethodModel.new(name: :require2, owner: Example, scope: Class)
Method_require3 = MethodModel.new(name: :require3, owner: Example, scope: Class)
Method_all_default = MethodModel.new(name: :all_default, owner: Example, scope: Class)
end # Examples

end # MethodModel

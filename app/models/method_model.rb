# Provide ActiveRecord methods to classes with no Database
class NoDB
include ActiveModel
def [](attribute_name)
	@mHash[attribute_name]
end #[]
def []=(attribute_name, value)
	@mHash[attribute_name]=value
end #[]
end #
class MethodModel < NoDB #<ActiveRecord::Base
def initialize(m,owner,scope)
	begin
		@mHash={}
		@mHash[:name]=m.to_sym
		@mHash[:owner]=owner
		@mHash[:scope]=scope

		if scope.to_sym==:class then
			theMethod=owner.method(m.to_sym)
		elsif owner.respond_to?(:new) then
			begin
#				theMethod=owner.new.method(m.to_sym)
				theMethod=nil
			rescue StandardError => exc
				@mHash[:exception]=exc
			end #begin
		else
			puts "  invalid method:"
			puts "m=:#{m}"
			puts "scope='#{scope}'"
			puts "owner=#{owner}"
		end #if
		if !theMethod.nil? then
			@mHash[:method]=theMethod
			@mHash[:arity]=theMethod.arity
			@mHash[:owner]=theMethod.owner
			if theMethod.respond_to?(:source_location)
				@mHash[:source_location]=theMethod.source_location
			else
				@mHash[:source_location]=nil
			end #if
			if theMethod.respond_to?(:parameters)
				@mHash[:parameters]=theMethod.parameters
			end #if
		else
			@mHash[:method]=nil
			@mHash[:arity]=nil
			@mHash[:owner]=nil
			@mHash[:source_location]=nil
			@mHash[:parameters]=nil
		end #if
		if m.to_s[/[a-zA-Z0-9_]+/,0]==m.to_s then
			@mHash[:instance_variable_defined]=theMethod.instance_variable_defined?(('@'+m.to_s))
		else
			@mHash[:instance_variable_defined]=nil
		end #if
		@mHash[:singleton]=singleton_methods.include?(m)
		begin
			@mHash[:protected]=protected_method_defined?(m)
			@mHash[:private]=private_method_defined?(m)
		rescue StandardError => exc
			@mHash[:exception]=exc
			@mHash[:protected]=nil
			@mHash[:private]=nil
		end #if
#	rescue StandardError => exc
#		@mHash[:owner]=owner
#		@mHash[:scope]=scope
#		@mHash[:exception]=exc
		#~ puts "exc=#{exc.inspect}"
#		mHash		
	end #begin
end #new
def self.constantized
	@@CONSTANTIZED||=Module.constants.map do |c|
		begin
			c=c.constantize
		rescue
			 puts "constant #{c.inspect} fails constanization"
			 nil
		 end #begin
	end #map
end #constantized
def self.classes
	ret=[]
	ObjectSpace.each_object(Class) do |c| 
		ret << c
	end #each_object
	ret=ret.sort{|x,y| (x.name)<=>(y.name)}
	return ret.uniq
end #classes
def self.modules
	ret=[]
	ObjectSpace.each_object(Module) do |mod| 
		ret << mod
	end #each_object
	ret=ret.sort{|x,y| x.name<=>y.name}
	return ret-classes
end #modules
def self.classes_and_modules
	return @@CLASSES_AND_MODULES||=classes+modules
end #classes_and_modules
def self.all_instance_methods
	return classes_and_modules.map { |c| c.instance_methods(false).map { |m| new(m,c,:instance) } }.flatten
end #all_instance_methods
def self.all_class_methods
	return classes_and_modules.map { |c| c.methods(false).map { |m| new(m,c,:class) } }.flatten
end #all_class_methods
def self.all_singleton_methods
	return classes_and_modules.map { |c| c.singleton_methods(false).map { |m| new(m,c,:singleton) } }.flatten
end #all_singleton_methods
def self.all
	@@ALL||=(all_class_methods + all_instance_methods + all_singleton_methods)
	return @@ALL
end #all
def self.first
	self.all.first
end #first
def self.find_by_name(name)
	self.all.find_all{|i| i[:name].to_sym==name.to_sym}
end #find_by_name
def self.owners_of(method_name)
	find_by_name(method_name).map {|i| {:owner => i[:owner],:scope => i[:scope]}}

end #owners_of
def return_type
end #
end #class
#class Stream < Enumerator
#end #Stream

# Provide ActiveRecord methods to classes with no Database
module NoDB
attr_reader :attributes
include ActiveModel
def initialize
	@attributes=ActiveSupport::HashWithIndifferentAccess.new
	
end #initialize
def [](attribute_name)
	@attributes[attribute_name]
end #[]
def []=(attribute_name, value)
	@attributes[attribute_name]=value
end #[]
def has_key?(key_name)
	return @attributes.has_key?(key_name)
end #has_key?
def keys
	return @attributes.keys
end #keys
end #
class MethodModel  #<ActiveRecord::Base
include NoDB
attr_reader :init_path
def self.method_query(m, owner)
	ObjectSpace.each_object(owner) do |object| 
		if object.respond_to?(m.to_sym) then
		begin
			theMethod=object.method(m.to_sym)
			return theMethod
		rescue ArgumentError => exc
			puts "exc=#{exc}, object=#{object.inspect}"
		end #begin
		end #if
	end #each_object
	return nil #no object found, new has side effects
end #method_query
def initialize(m,owner=nil,scope=nil)
	super()
	if !m.nil? && owner.nil? && scope.nil? then # only one argument (method)
		theMethod=m
		m=theMethod.name # elsewhere
		attributes[:name]=theMethod.name
		attributes[:method]=theMethod
		attributes[:scope]=theMethod.owner.class
		attributes[:arity]=theMethod.arity
		attributes[:owner]=theMethod.owner
		@init_path = [:object_space_method]
		if theMethod.respond_to?(:source_location)
			attributes[:source_location]=theMethod.source_location
			@init_path << :source_location
		else
			attributes[:source_location]=nil
			@init_path << :not_source_location
		end #if
		if theMethod.respond_to?(:parameters)
			attributes[:parameters]=theMethod.parameters
			@init_path << :parameters
		end #if
	else #3 arguments
		attributes[:name]=m.to_sym
		attributes[:owner]=owner
		attributes[:scope]=scope
		@init_path = [:init]

		if scope.to_sym==:class then
			theMethod=owner.method(m.to_sym)
			@init_path << :class
		else
			theMethod=MethodModel.method_query(m, owner)
		end #if
		if !theMethod.nil? then
			attributes[:method]=theMethod
			attributes[:arity]=theMethod.arity
			attributes[:owner]=theMethod.owner
			@init_path << :theMethod_not_nil
			if theMethod.respond_to?(:source_location)
				attributes[:source_location]=theMethod.source_location
				@init_path << :source_location
			else
				attributes[:source_location]=nil
				@init_path << :not_source_location
			end #if
			if theMethod.respond_to?(:parameters)
				attributes[:parameters]=theMethod.parameters
				@init_path << :parameters
			end #if
		else
			attributes[:method]=nil
			attributes[:arity]=nil
			attributes[:owner]=nil
			attributes[:source_location]=nil
			attributes[:parameters]=nil
			@init_path << :theMethod_nil
		end #if
	end #if
	begin
		attributes[:protected]=protected_method_defined?(m)
		attributes[:private]=private_method_defined?(m)
		@init_path << :protected
	rescue StandardError => exc
		attributes[:exception]=exc
		attributes[:protected]=nil
		attributes[:private]=nil
		@init_path << :rescue_protected
	end #if
	if m.to_s[/[a-zA-Z0-9_]+/,0]==m.to_s then
		attributes[:instance_variable_defined]=theMethod.instance_variable_defined?(('@'+m.to_s))
		@init_path << :alphanumeric
	else
		attributes[:instance_variable_defined]=nil
		@init_path << :not_alphanumeric
	end #if
	attributes[:singleton]=singleton_methods.include?(m)
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
def self.all_methods
	ret=[]
	ObjectSpace.each_object(Method) do |m| 
		ret << m
	end #each_object
	ret=ret.sort{|x,y| (x.name)<=>(y.name)}
	return ret.uniq
end #methods
def self.classes
	ret=[]
	ObjectSpace.each_object(Class) do |c| 
		ret << c
	end #each_object
	ret=ret.sort{|x,y| (x.name)<=>(y.name)}
	return ret 
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
	@@ALL||=(all_methods.map {|method| new(method)})
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
end #class
#class Stream < Enumerator
#end #Stream

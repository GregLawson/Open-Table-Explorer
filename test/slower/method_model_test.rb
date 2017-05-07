###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
class LongMethodModelTest < TestCase
def self.method_query(m, owner)
	ObjectSpace.each_object(owner) do |object| 
		if object.respond_to?(m.to_sym) then
		begin
			theMethod=object.method(m.to_sym)
			return theMethod
		rescue ArgumentError, NameError => exc
			puts "exc=#{exc}, object=#{object.inspect}"
		end #begin
		end #if
	end #each_object
	return nil #no object found, new has side effects
end #method_query
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
	ret=ret.map {|method| new(method)}
	return ret #.uniq
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
	@@ALL||=(all_methods+all_instance_methods+all_class_methods+all_singleton_methods)
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
end # MethodTest

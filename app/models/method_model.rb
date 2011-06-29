class MethodModel < ActiveRecord::Base
def self.method_record(m,owner,scope)
	begin
		mHash={}
		mHash[:name]=m
		theMethod=method(m.to_sym)
		mHash[:method]=theMethod
		mHash[:arity]=theMethod.arity
		mHash[:owner]=theMethod.owner
		mHash[:instance_variable_defined]=theMethod.instance_variable_defined?(('@'+m))
		mHash[:singleton]=singleton_methods.include?(m)
		mHash[:scope]=self.class==Class ? 'Class': 'Instance'
		mHash[:protected]=protected_method_defined?(m)
		mHash[:private]=private_method_defined?(m)
		mHash[:parameters]=theMethod.parameters
		mHash[:source_location]=theMethod.source_location
		mHash		
	rescue StandardError => exc
		mHash[:owner]=owner
		mHash[:scope]=scope
		mHash[:exception]=exc
		#~ puts "exc=#{exc.inspect}"
		mHash		
	end #begin
end #def
def self.constantized
	@@CONSTANTIZED||=Module.constants.map do |c|
		begin
			c=c.constantize
		rescue
			 puts "constant #{c.inspect} fails constanization"
			 nil
		 end #begin
	end #map
end #def
def self.classes
	ret=[]
	ObjectSpace.each_object(Class) do |c| 
		ret << c
	end #each_object
	ret=ret.sort{|x,y| (x.name)<=>(y.name)}
	return ret.uniq
end #def
def self.modules
	ret=[]
	ObjectSpace.each_object(Module) do |mod| 
		ret << mod
	end #each_object
	ret=ret.sort{|x,y| x.name<=>y.name}
	return ret.uniq
end #def
def self.classes_and_modules
	return @@CLASSES_AND_MODULES||=classes+modules
end #def
def method_names
	
end #end
def self.all
	@@ALL||=(classes_and_modules.map { |c| c.methods(false).map { |m| method_record(m,c,:class) } } +
	classes_and_modules.map { |c| c.instance_methods(false).map { |m| method_record(m,c,:instance) } } +
	classes_and_modules.map { |c| c.singleton_methods(false).map { |m| method_record(m,c,:singleton) } }).flatten
end #def
end #class

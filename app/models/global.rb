###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
module Global
def Global.activeRecordTableNotCreatedYet?(obj)
	return (obj.class.inspect=~/^[a-zA-Z0-9_]+\(Table doesn\'t exist\)/)==0
end #def
def Global.objectName(obj,verbose=false)
	if obj.nil? then
		return "#{obj} is nil."
	elsif obj.class.name=='Symbol' then
		#puts "find_symbol(obj)=#{find_symbol(obj)}"
		return "#{obj.to_s}"
	elsif obj.class.name=='Module' then
		puts("obj.name=#{obj.name}")
		puts("nesting.inspect=#{nesting.inspect}")
		return "Module #{obj.name}"
	elsif activeRecordTableNotCreatedYet?(obj) then
		return "Active_Record #{obj.class.inspect}"
	else
		if obj.respond_to?(:name) then
			puts("obj.name=#{obj.name}")
		else
			return "obj.to_s=#{obj.to_s} has no name."
		end
	end

end
def Global.objectClass(obj,verbose=false)
	if obj.nil? then
		return "#{obj} is nil."
	elsif obj.class.name=='Symbol' then
		#puts "find_symbol(obj)=#{find_symbol(obj)}"
		return "Symbol"
	elsif obj.class.name=='Module' then
		puts("obj.name=#{obj.name}") if verbose
		puts("nesting.inspect=#{nesting.inspect}") if verbose
		return "Module #{obj.name}"
	elsif activeRecordTableNotCreatedYet?(obj) then
		return "Active_Record #{obj.class.inspect}"
	else
		obj=obj.class
		puts("obj.name=#{obj.name}") if verbose
		if obj.respond_to?(:superclass) then
			#puts("obj.superclass=#{obj.superclass}")
			puts("obj.superclass.name=#{obj.superclass.name}") if verbose
			return "Class #{obj.name} subclass of #{obj.superclass.name}"
		else
			return "obj Class #{obj.name} has no superclass."
		end
	end

end
def Global.canonicalName(obj,verbose=false)

	if obj.nil? then
		return "#{obj} is nil."
	elsif obj.class.name=='Symbol' then
		#puts "find_symbol(obj)=#{find_symbol(obj)}"
		return "Symbol :#{obj.to_s}"
	elsif obj.class.name=='Module' then
		puts("obj.name=#{obj.name}") if verbose
		puts("nesting.inspect=#{nesting.inspect}") if verbose
		return "Module #{obj.name}"
	elsif activeRecordTableNotCreatedYet?(obj) then
		return "Active_Record #{obj.class.inspect}"
	elsif obj.instance_of?(Class) then
		return "Class"
	elsif obj.instance_of?(Array) then
		return "Array"
	elsif !obj.to_s[/#<ActiveRecord::Relation:/].empty? then
		return "#<ActiveRecord::Relation:"
	else
		puts "obj.to_s=#{obj.to_s}"
		puts "obj=#{obj.inspect}"
		if obj.respond_to?(:name) then
			puts("obj.name=#{obj.name}") if verbose
			if obj.respond_to?(:superclass) then
				puts("obj.superclass=#{obj.superclass}") if verbose
				puts("obj.superclass.name=#{obj.superclass.name}") if verbose
				return "Class #{obj.name} subclass of #{obj.superclass.name}"
			else
				return "obj Class #{obj.name} has no superclass."
			end
		else
			return "obj.to_s=#{obj.to_s} has no name."
		end
	end

end
def Global.whoAmI(obj,verbose=false)
	puts("obj=#{obj}") if verbose
	puts("obj.class=#{obj.class}") if verbose
	puts("obj.class.name=#{obj.class.name}") if verbose
	puts("obj.to_s=#{obj.to_s}") if verbose
	puts("obj.inspect=#{obj.inspect}") if verbose
#	puts("obj.object_id=#{obj.object_id}") if verbose
	if obj.respond_to?(:name) then
		puts("obj.name=#{obj.name}") if verbose
	else
		puts("obj has no name. obj.inspect=#{obj.inspect}.") if verbose
	end
	if obj.respond_to?(:human_name) then
		puts("obj.model_name.collection=#{obj.model_name.collection}") if verbose
		puts("obj.human_name=#{obj.human_name}") if verbose
		puts("obj.model_name.element=#{obj.model_name.element}") if verbose
		puts("obj.model_name.partial_path=#{obj.model_name.partial_path}") if verbose
		puts("obj.model_name.plural=#{obj.model_name.plural}") if verbose
		puts("obj.model_name.singular=#{obj.model_name.singular}") if verbose
	end
	puts("noninherited_public_instance_methods(obj).inspect=#{noninherited_public_instance_methods(obj).inspect}") if verbose
	puts("noninherited_public_class_methods(obj).inspect=#{noninherited_public_class_methods(obj).inspect}") if verbose
	if obj.nil? then
		return "#{obj} is nil."
	elsif obj.class.name=='Symbol' then
		#puts "find_symbol(obj)=#{find_symbol(obj)}"
		return "Symbol :#{obj.to_s}"
	elsif obj.class.name=='Module' then
		puts("obj.name=#{obj.name}") if verbose
		puts("nesting.inspect=#{nesting.inspect}") if verbose
		return "Module #{obj.name}"
	else
		if obj.respond_to?(:name) then
			puts("obj.name=#{obj.name}") if verbose
			if obj.respond_to?(:superclass) then
				puts("obj.superclass=#{obj.superclass}") if verbose
				puts("obj.superclass.name=#{obj.superclass.name}") if verbose
				return "Class #{obj.name} subclass of #{obj.superclass.name}"
			else
				return "obj Class #{obj.name} has no superclass."
			end
		else
			return "obj.inspect=#{obj.inspect} has no name."
		end
	end

end #def
def Global.relationship(obj=self)
	puts "self is #{self.whoAmI}"
	puts "obj is #{whoAmI(obj)}"
	if obj.nil? then
		puts "#{obj} is nil."
	elsif obj.class.name=='Symbol' then
	else
		puts "obj.name=#{obj.name}"
		if is_a?(obj) then
			puts "#{self.name} is the class of (or superclass of) #{obj}"
		end
	end
	if self==obj then
		puts "#{obj} is the same(==) as #{self.name}"
	 
	elsif respond_to?(obj) then
		puts "#{self.name} will respond to #{obj}"
	 
	elsif singleton_methods.include?(obj) then
		puts "#{obj} is a include?d modules of #{self.name}"
	elsif included_modules.include?(obj) then
		puts "#{obj} is a include?d modules of #{self.name}"
#	elsif self.class_variable_defined?(obj) then
#		puts "#{obj} is declared as a class variable."
#	elsif self.const_defined? then
#		puts "#{obj} is is a defined constant."
	
	elsif public_instance_methods.include?(obj) then
		puts "#{obj} is a public instance method of #{self.name}"
	elsif public_methods.include?(obj) then
		puts "#{obj} is a public method of #{self.name}"
	elsif protected_methods.include?(obj) then
		puts "#{obj} is a protected method of #{self.name}"
	elsif private_methods.include?(obj) then
		puts "#{obj} is a private method of #{self.name}"
	elsif instance_variables.include?(obj) then
		puts "#{obj} is a instance variables of #{self.name}"
	elsif class_variables.include?(obj) then
		puts "#{obj} is a class variables of #{self.name}"
	elsif included_modules.include?(obj) then
		puts "#{obj} is a module of #{self.name}"
	elsif instance_methods.include?(obj) then
		puts "#{obj} is an instance module of #{self.name}"
	elsif ancestors.include?(obj) then
		puts "#{obj} is an ancestor module of #{self.name}"
	else
		puts "Can't figure out relation between #{obj.inspect} and #{self.inspect}"
	end #if
end #def
end #module

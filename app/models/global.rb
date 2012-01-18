###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# contains mostly functions created for testing / debugging but not dependant on ActiveRecord
class Set
def set_inspect
	return "#{inspect}; #{map {|h| h.object_identities}.join(', ')}"
end #set_inspect

end #Set
class Object
def enumerate_single(enumerator_method, &proc)
	result=[self].enumerate(enumerator_method, &proc) #simulate array
	if result.instance_of?(Array) then # map
		return result[0] #discard simulated array
	else # reduction method (not map)
		return result
	end #if
end #enumerate_single
def enumerate(enumerator_method, &proc)
	if instance_of?(Array) then
		method(enumerator_method).call(&proc)
	else
		enumerate_single(enumerator_method, &proc)		
	end #if
end #enumerate
end #Object
class Module
def instance_methods_from_class(all=false)
	return self.instance_methods(all)
end #instance_methods_from_class
def instance_respond_to?(method_name)
	return instance_methods_from_class.include?(method_name.to_s)
end #instance_respond_to
# misspelled?
def similar_methods(symbol)
	singular='^'+symbol.to_s.singularize
	plural='^'+symbol.to_s.pluralize
	table='^'+symbol.to_s.tableize
	return (matching_instance_methods(singular) + matching_instance_methods(plural) + matching_instance_methods(table)).uniq
end #similar_methods
def matching_instance_methods(regexp,all=false)
	if regexp.instance_of?(Symbol) then
		regexp=regexp.to_s
	end #if
	instance_methods_from_class(all).select {|m| m[Regexp.new(regexp),0] }
end #matching_instance_methods
def matching_class_methods(regexp,all=false)
	if regexp.instance_of?(Symbol) then
		regexp=regexp.to_s
	end #if
	self.public_methods(all).select {|m| m[Regexp.new(regexp),0] }
end #def
end #module
class Object
#~ require 'IncludeModuleClassMethods.rb'
 #~ mixin_class_methods { |klass|
 #~ puts "Module Acquisition has been included by #{klass}" if $VERBOSE
 #~ }
#~ define_class_methods {
#~ } #define_class_methods
def object_identities
	return "<#{objectClass} \##{object_id}{#{hash}},#{to_s},#{inspect}>"
end #object_identities
def objectKind
	if nil? then
		return "nil"
	elsif self.class.name=='Symbol' then
		return "Symbol"
	elsif self.class.name=='Module' then
		return "Module"
	elsif self.class.name=='String' then
		return "String"
	else
		if respond_to?(:superclass) then
			return "Class"
		else
			return "Class #{self.class.name} has no superclass."
		end
	end

end  #objectKind
def objectClass(verbose=false)
	if nil? then
		return "NilClass"
	elsif self.class.name=='Symbol' then
		return "Symbol"
	elsif self.class.name=='Module' then
		return "Module #{name}"
	else
		if respond_to?(:superclass) then
			return "#{self.class.name} subclass of #{self.class.superclass.name}"
		else
			return "#{self.class.name}"
		end
	end

end #objectClass
def objectName(verbose=false)
	if nil? then
		return "#{obj} is nil."
	elsif self.class.name=='Symbol' then
		#puts "find_symbol(obj)=#{find_symbol(obj)}"
		return "#{to_s}"
	elsif self.class.name=='Module' then
		puts("name=#{name}")
		puts("nesting.inspect=#{nesting.inspect}")
		return "Module #{name}"
	elsif activeRecordTableNotCreatedYet?(obj) then
		return "Active_Record #{self.class.inspect}"
	else
		if respond_to?(:name) then
			puts("name=#{name}")
		else
			return "to_s=#{to_s} has no name."
		end
	end

end
def canonicalName(verbose=false)
	#~ puts "inspect=#{inspect}"
	#~ puts "respond_to?(:to_s)=#{respond_to?(:to_s)}"
	if nil? then
		return "nil"
	elsif self.class.name=='Symbol' then
		#puts "find_symbol(obj)=#{find_symbol(obj)}"
		return "Symbol :#{to_s}"
	elsif self.class.name=='Module' then
		if name=='' then
			return "Module Id:#{sprintf("%X",object_id)} in (#{ancestors.inspect})"
		else
			return "Module #{name}"
		end #if
	elsif instance_of?(ActiveRecord::Base) then
		return "ActiveRecord::Base #{self.class.name}"		
	elsif kind_of?(ActiveRecord::Base) then
		return "ActiveRecord::Base subclass #{self.class.name}"		
	elsif Generic_Table.activeRecordTableNotCreatedYet?(self) then
		return "Active_Record #{self.class.inspect}"
	elsif instance_of?(Class) then
		return "Class #{name}"
	elsif instance_of?(Array) then
		return "Array instance"
	elsif kind_of?(Account) then
		return "Account"
	elsif instance_of?(Account) then
		return "Account"
	elsif !respond_to?(:to_s) then
		return "#{self.class.name} does not respond to :to_s"
	elsif to_s.nil? then
		return "#{self.class.name} to_s returns nil"
	elsif to_s.empty? then
		return "#{self.class.name} to_s returns empty"
	elsif !to_s[/#<ActiveRecord::Relation:/].nil? then
		if !to_s[/#<ActiveRecord::Relation:/].empty? then
			return "#{self.class.name} #<ActiveRecord::Relation:"
		else
			return "#{self.class.name}.!to_s[/#<ActiveRecord::Relation:/] is not nil"
		end
	else
		#~ puts "to_s=#{to_s}"
		#~ puts "obj=#{inspect}"
		if respond_to?(:name) then
			puts("name=#{name}") if verbose
			if respond_to?(:superclass) then
				puts("superclass=#{superclass}") if verbose
				puts("superclass.name=#{superclass.name}") if verbose
				return "Class #{name} subclass of #{superclass.name}"
			else
				return "obj Class #{name} has no superclass."
			end
		else
			return "to_s=#{to_s} has no name."
		end
	end

end
def noninherited_public_instance_methods
	puts "noninherited_public_instance_methods in class Object called"
	return self.class.public_instance_methods(false)
end #noninherited_public_instance_methods
def noninherited_public_class_methods
	self.class.methods-self.class.superclass.methods
end #noninherited_public_class_methods
def whoAmI(verbose=false)
	obj=self
#	puts("obj=#{obj}") if verbose
#	puts("obj.class=#{obj.class}") if verbose
#	puts("obj.class.name=#{obj.class.name}") if verbose
#	puts("obj.to_s=#{obj.to_s}") if verbose
#	puts("obj.inspect=#{obj.inspect}") if verbose
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

end #whoAmI
def relationship(obj=self)
	puts "self is #{self.whoAmI}"
	puts "obj is #{obj.whoAmI}"
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
end #relationship
def module?
	self.class.name=='Module'
end #module
def noninherited_modules
	if module? then
		return ancestors-[self]
	else
		return ancestors-[self]-superclass.ancestors
	end #if
end #noninherited_modules
def module_included?(symbol)
	if symbol.kind_of?(Class) then
		ancestors.map{|a| a.name}.include?(symbol.name)
	else
		ancestors.map{|a| a.name}.include?(symbol.to_s)
	end #if
end #def
def method_contexts(depth=0)
	if instance_of?(Class) then
		ancestors[0..depth].uniq
	else
		[self]+self.class.ancestors[0..depth].uniq
	end #if
end #def
def context_names(depth=0)
	method_contexts(depth).map{|c| c.canonicalName}
end #def
def method_context(methodName)
	if respond_to(methodName) then
		matching_methods_in_context(methodName)
	else
		nil
	end #if
end #def
def matching_methods_in_context(regexp,depth=0)
	ret={}
	method_contexts(depth).map do |context|
		instance_meths=context.matching_instance_methods(regexp)
		ret[context.canonicalName]=instance_meths # label level
	end #map
	ret
end #def

end #class
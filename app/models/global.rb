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
def Global.canonicalName(obj,verbose=false)

	if obj.nil? then
		return "#{obj} is nil."
	elsif obj.class.name=='Symbol' then
		#puts "find_symbol(obj)=#{find_symbol(obj)}"
		return "Symbol :#{obj.to_s}has no superclass"
	elsif obj.class.name=='Module' then
		log.info("obj.name=#{obj.name}")
		log.info("nesting.inspect=#{nesting.inspect}")
		return "Module #{obj.name}"
	elsif activeRecordTableNotCreatedYet?(obj) then
		return "Active_Record #{obj.class.inspect}"
	else
		if obj.respond_to?(:name) then
			log.info("obj.name=#{obj.name}")
			if obj.respond_to?(:superclass) then
				log.info("obj.superclass=#{obj.superclass}")
				log.info("obj.superclass.name=#{obj.superclass.name}")
				return "Class #{obj.name} subclass of #{obj.superclass.name}"
			else
				return "obj Class #{obj.name} has no superclass."
			end
		else
			return "obj.to_s=#{obj.to_s} has no name."
		end
	end

end
def Global.noninherited_public_instance_methods(obj)
	return public_instance_methods(false)-Class.public_instance_methods
end
def Global.noninherited_public_class_methods(obj)
	if obj.respond_to?(:superclass) then
		return obj.methods-obj.superclass.methods-noninherited_public_instance_methods(obj)
	else
		return obj.methods-noninherited_public_instance_methods(obj)
	end
end
def Global.whoAmI(obj,verbose=false)
	log.info("obj=#{obj}")
	log.info("obj.class=#{obj.class}")
	log.info("obj.class.name=#{obj.class.name}")
	log.info("obj.to_s=#{obj.to_s}")
	log.info("obj.inspect=#{obj.inspect}")
#	log.info("obj.object_id=#{obj.object_id}")
	if obj.respond_to?(:name) then
		log.info("obj.name=#{obj.name}")
	else
		log.info("obj has no name. obj.inspect=#{obj.inspect}.")
	end
	if obj.respond_to?(:human_name) then
		log.info("obj.model_name.collection=#{obj.model_name.collection}")
		log.info("obj.human_name=#{obj.human_name}")
		log.info("obj.model_name.element=#{obj.model_name.element}")
		log.info("obj.model_name.partial_path=#{obj.model_name.partial_path}")
		log.info("obj.model_name.plural=#{obj.model_name.plural}")
		log.info("obj.model_name.singular=#{obj.model_name.singular}")
	end
	log.info("noninherited_public_instance_methods(obj).inspect=#{noninherited_public_instance_methods(obj).inspect}")
	log.info("noninherited_public_class_methods(obj).inspect=#{noninherited_public_class_methods(obj).inspect}")
	if obj.nil? then
		return "#{obj} is nil."
	elsif obj.class.name=='Symbol' then
		#puts "find_symbol(obj)=#{find_symbol(obj)}"
		return "Symbol :#{obj.to_s}has no superclass"
	elsif obj.class.name=='Module' then
		log.info("obj.name=#{obj.name}")
		log.info("nesting.inspect=#{nesting.inspect}")
		return "Module #{obj.name}"
	else
		if obj.respond_to?(:name) then
			log.info("obj.name=#{obj.name}")
			if obj.respond_to?(:superclass) then
				log.info("obj.superclass=#{obj.superclass}")
				log.info("obj.superclass.name=#{obj.superclass.name}")
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


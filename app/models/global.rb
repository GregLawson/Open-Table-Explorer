###########################################################################
#    Copyright (C) 2011-2014 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# contains mostly functions created for testing / debugging but not dependant on ActiveRecord
class Set
  def set_inspect
    "#{inspect}; #{map(&:object_identities).join(', ')}"
  end # set_inspect
end # Set
class Module
  def instance_methods_from_class(all = false)
    instance_methods(all)
  end # instance_methods_from_class

  def instance_respond_to?(method_name, all = false)
    instance_methods_from_class(all).include?(method_name.to_sym)
  end # instance_respond_to

  # misspelled?
  def similar_methods(symbol)
    singular = '^' + symbol.to_s.singularize
    plural = '^' + symbol.to_s.pluralize
    table = '^' + symbol.to_s.tableize
    (matching_instance_methods(singular) + matching_instance_methods(plural) + matching_instance_methods(table)).uniq
  end # similar_methods

  def matching_instance_methods(regexp, all = false)
    if regexp.instance_of?(Symbol)
      regexp = regexp.to_s
    end # if
    instance_methods_from_class(all).select { |m| m[Regexp.new(regexp), 0] }
  end # matching_instance_methods

  def matching_class_methods(regexp, all = false)
    if regexp.instance_of?(Symbol)
      regexp = regexp.to_s
    end # if
    public_methods(all).select { |m| m[Regexp.new(regexp), 0] }
  end # matching_class_methods
end # module
class Object
  def info(message)
    if $VERBOSE
      $stdout.puts message
    end # if
  end # info

  def object_identities
    "<#{objectClass} \##{object_id}{#{hash}},#{self},#{inspect}>"
  end # object_identities

  def objectKind
    if nil?
      return 'nil'
    elsif self.class.name == 'Symbol'
      return 'Symbol'
    elsif self.class.name == 'Module'
      return 'Module'
    elsif self.class.name == 'String'
      return 'String'
    else
      if respond_to?(:superclass)
        return 'Class'
      else
        return "Class #{self.class.name} has no superclass."
      end
    end
  end # objectKind

  def objectClass(_verbose = false)
    if nil?
      return 'NilClass'
    elsif self.class.name == 'Symbol'
      return 'Symbol'
    elsif self.class.name == 'Module'
      return "Module #{name}"
    else
      if respond_to?(:superclass)
        return "#{self.class.name} subclass of #{self.class.superclass.name}"
      else
        return self.class.name.to_s
      end
    end
  end # objectClass

  def objectName(_verbose = false)
    if nil?
      return "#{obj.inspect} is nil."
    elsif self.class.name == 'Symbol'
      # puts "find_symbol(obj)=#{find_symbol(obj)}"
      return ":#{self}"
    elsif self.class.name == 'Module'
      puts("name=#{name}")
      puts("nesting.inspect=#{nesting.inspect}")
      return "Module #{name}"
    elsif activeRecordTableNotCreatedYet?(obj)
      return "Active_Record #{self.class.inspect}"
    else
      if respond_to?(:name)
        puts("name=#{name}")
      else
        return "inspect=#{inspect} has no name."
      end
    end
  end

  def canonicalName
    # ~ puts "inspect=#{inspect}"
    # ~ puts "respond_to?(:to_s)=#{respond_to?(:to_s)}"
    if nil?
      return 'nil'
    elsif instance_of?(Class)
      return "Class #{name}"
    elsif self.class.name == 'Symbol'
      return "Symbol :#{self}"
    elsif self.class.name == 'Module'
      if name == ''
        return "Module Id:#{sprintf('%X', object_id)} in (#{ancestors.inspect})"
      else
        return "Module #{name}"
      end # if
    elsif self.class.name == 'ActiveRecord::Base'
      return "ActiveRecord::Base #{self.class.name}"
    elsif instance_of?(Array)
      return 'Array instance'
    elsif !respond_to?(:to_s)
      return "#{self.class.name} does not respond to :to_s"
    elsif to_s.nil?
      return "#{self.class.name} to_s returns nil"
    elsif to_s.empty?
      return "#{self.class.name} to_s returns empty"
    elsif !to_s[/#<ActiveRecord::Relation:/].nil?
      if !to_s[/#<ActiveRecord::Relation:/].empty?
        return "#{self.class.name} #<ActiveRecord::Relation:"
      else
        return "#{self.class.name}.!to_s[/#<ActiveRecord::Relation:/] is not nil"
      end
    else
      if respond_to?(:name)
        if respond_to?(:superclass)
          return "Class #{name} subclass of #{superclass.name}"
        else
          return "obj Class #{name} has no superclass."
        end
      else
        return "inspect=#{inspect} has no name."
      end
    end
  end

  def noninherited_public_instance_methods
    puts 'noninherited_public_instance_methods in class Object called'
    self.class.public_instance_methods(false)
  end # noninherited_public_instance_methods

  def noninherited_public_class_methods
    self.class.methods - self.class.superclass.methods
  end # noninherited_public_class_methods

  def whoAmI(verbose = false)
    obj = self
    #	puts("obj=#{obj}") if verbose
    #	puts("obj.class=#{obj.class}") if verbose
    #	puts("obj.class.name=#{obj.class.name}") if verbose
    #	puts("obj.to_s=#{obj.to_s}") if verbose
    #	puts("obj.inspect=#{obj.inspect}") if verbose
    #	puts("obj.object_id=#{obj.object_id}") if verbose
    if obj.respond_to?(:name)
      puts("obj.name=#{obj.name}") if verbose
    else
      puts("obj has no name. obj.inspect=#{obj.inspect}.") if verbose
    end
    if obj.respond_to?(:human_name)
      puts("obj.model_name.collection=#{obj.model_name.collection}") if verbose
      puts("obj.human_name=#{obj.human_name}") if verbose
      puts("obj.model_name.element=#{obj.model_name.element}") if verbose
      puts("obj.model_name.partial_path=#{obj.model_name.partial_path}") if verbose
      puts("obj.model_name.plural=#{obj.model_name.plural}") if verbose
      puts("obj.model_name.singular=#{obj.model_name.singular}") if verbose
    end
    puts("noninherited_public_instance_methods(obj).inspect=#{noninherited_public_instance_methods(obj).inspect}") if verbose
    puts("noninherited_public_class_methods(obj).inspect=#{noninherited_public_class_methods(obj).inspect}") if verbose
    if obj.nil?
      return "#{obj} is nil."
    elsif obj.class.name == 'Symbol'
      # puts "find_symbol(obj)=#{find_symbol(obj)}"
      return "Symbol :#{obj}"
    elsif obj.class.name == 'Module'
      puts("obj.name=#{obj.name}") if verbose
      puts("nesting.inspect=#{nesting.inspect}") if verbose
      return "Module #{obj.name}"
    else
      if obj.respond_to?(:name)
        puts("obj.name=#{obj.name}") if verbose
        if obj.respond_to?(:superclass)
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
  end # whoAmI

  def relationship(obj = self)
    puts "self is #{whoAmI}"
    puts "obj is #{obj.whoAmI}"
    if obj.nil?
      puts "#{obj} is nil."
    elsif obj.class.name == 'Symbol'
    else
      puts "obj.name=#{obj.name}"
      puts "#{name} is the class of (or superclass of) #{obj}" if is_a?(obj)
    end
    if self == obj
      puts "#{obj} is the same(==) as #{name}"

    elsif respond_to?(obj)
      puts "#{name} will respond to #{obj}"

    elsif singleton_methods.include?(obj)
      puts "#{obj} is a include?d modules of #{name}"
    elsif included_modules.include?(obj)
      puts "#{obj} is a include?d modules of #{name}"
    #	elsif self.class_variable_defined?(obj) then
    #		puts "#{obj} is declared as a class variable."
    #	elsif self.const_defined? then
    #		puts "#{obj} is is a defined constant."

    elsif public_instance_methods.include?(obj)
      puts "#{obj} is a public instance method of #{name}"
    elsif public_methods.include?(obj)
      puts "#{obj} is a public method of #{name}"
    elsif protected_methods.include?(obj)
      puts "#{obj} is a protected method of #{name}"
    elsif private_methods.include?(obj)
      puts "#{obj} is a private method of #{name}"
    elsif instance_variables.include?(obj)
      puts "#{obj} is a instance variables of #{name}"
    elsif class_variables.include?(obj)
      puts "#{obj} is a class variables of #{name}"
    elsif included_modules.include?(obj)
      puts "#{obj} is a module of #{name}"
    elsif instance_methods.include?(obj)
      puts "#{obj} is an instance module of #{name}"
    elsif ancestors.include?(obj)
      puts "#{obj} is an ancestor module of #{name}"
    else
      puts "Can't figure out relation between #{obj.inspect} and #{inspect}"
    end # if
  end # relationship

  def module?
    self.class.name == 'Module'
  end # module

  def noninherited_modules
    if module?
      return ancestors - [self]
    else
      return ancestors - [self] - superclass.ancestors
    end # if
  end # noninherited_modules

  def module_included?(symbol)
    if symbol.is_a?(Class)
      ancestors.map(&:name).include?(symbol.name)
    else
      ancestors.map(&:name).include?(symbol.to_s)
    end # if
  end # def

  def method_contexts(depth = 0)
    if instance_of?(Class)
      ancestors[0..depth].uniq
    else
      [self] + self.class.ancestors[0..depth].uniq
    end # if
  end # def

  def context_names(depth = 0)
    method_contexts(depth).map(&:canonicalName)
  end # def

  def method_context(methodName)
    if respond_to(methodName)
      matching_methods_in_context(methodName)
    end # if
  end # def

  def matching_methods_in_context(regexp, depth = 0)
    ret = {}
    method_contexts(depth).map do |context|
      instance_meths = context.matching_instance_methods(regexp)
      ret[context.canonicalName] = instance_meths # label level
    end # map
    ret
  end # def
end # class

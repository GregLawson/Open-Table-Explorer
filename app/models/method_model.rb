###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
# require_relative '../../app/models/no_db.rb'
class Method # monkey patch
  def default_arguments?
    if arity < 0
      true
    else
      false
    end # if
    end # default_arguments

  def required_arguments
    if default_arguments?
      -(arity + 1)
    else
      arity
    end # if
  end # required_arguments
end # Method

class MethodModel # <ActiveRecord::Base
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    Default_method_selection = { instance: true, method_name_selection: /.+/, include_inherited: false }.freeze
    Default_ancestor_method_selection = { instance: true, method_name_selection: /.+/, ancestor_selection: :ancestors }.freeze
  end # DefinitionalConstants
  include DefinitionalConstants
  module DefinitionalClassMethods
    include DefinitionalConstants
    def superclasses(klass)
      klass.ancestors - klass.included_modules
    end # superclasses

    def apply_selection_defaults(selection, defaults)
      raise 'selection.inspect = ' + selection.inspect unless selection.instance_of?(Hash)
      raise defaults.inspect unless defaults.instance_of?(Hash)
      defaults.each_pair do |key, value|
        if selection[key].nil?
          selection[key] = value # default
        end # if
      end # each_pair
      selection
    end # apply_selection_defaults

    def method_names(klass, selection = Default_method_selection)
      selection = apply_selection_defaults(selection, Default_method_selection)
      method_names = if selection[:instance]
                       klass.instance_methods(selection[:include_inherited])
                     else
                       klass.methods(selection[:include_inherited])
      end # if
      if selection[:method_name_selection].instance_of?(Regexp)
        method_name_list = method_names.select do |method_name|
          method_name.to_s.match(selection[:method_name_selection])
        end # select
      elsif selection[:method_name_selection].instance_of?(Array)
        method_name_list = selection[:method_name_selection]
      elsif selection[:method_name_selection].instance_of?(Symbol)
        method_name_list = [selection[:method_name_selection]]
      else
        raise selection.inspect
      end # if
    end # method_names

    # returns Hash with unique ancestors as keys and method_names(klass) as values.
    def ancestor_method_names(klass, selection = Default_ancestor_method_selection)
      selection = apply_selection_defaults(selection, Default_ancestor_method_selection)
      ret = {}
      ancestors = case selection[:ancestor_selection]
                  when :ancestors then klass.ancestors
                  when :modules_included then klass.modules_included
                  when :superclasses then superclasses(klass)
                  else
                    klass.ancestors.select do |ancestor|
                      ancestor.name.to_s.match(ancestor_selection)
                    end # select
              end # case
      ancestors.map do |ancestor|
        method_names = method_names(ancestor, selection)
        unless method_names.empty? && selection[:method_name_selection] != Default_method_selection[:method_name_selection]
          ret[ancestor] = method_names(ancestor, selection)
        end #
      end # map
      ret
    end # ancestor_method_names

    def ancestor_method_name(klass, method_name, selection = Default_ancestor_method_selection)
      # if instance = true, check instance_methods; if instance = false, class/module methods
      selection = apply_selection_defaults(selection, Default_ancestor_method_selection)
      selection[:method_name_selection] = [method_name] # one specific method name
      ancestor_method_names(klass, selection)
    end # ancestor_method_name
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods
  module ClassMethods
    # include DefinitionalConstants
    def init_path(m, class_of_receiver = nil, class_method = nil)
      if !m.nil? && class_of_receiver.nil? && class_method.nil? # only one argument (method)
        theMethod = m
        init_path = [:object_space_method]
        init_path << if theMethod.respond_to?(:source_location)
                       :source_location
                     else
                       :not_source_location
                     end # if
        if theMethod.respond_to?(:parameters)
          init_path << :parameters
        end # if
      else # 3 arguments
        init_path = [:init]

        if class_method.to_sym == :class
          init_path << :class
        else
          theMethod = MethodModel.method_query(m, class_of_receiver)
        end # if
        if !theMethod.nil?
          init_path << :theMethod_not_nil
          init_path << if theMethod.respond_to?(:source_location)
                         :source_location
                       else
                         :not_source_location
                       end # if
          if theMethod.respond_to?(:parameters)
            init_path << :parameters
          end # if
        else
          init_path << :theMethod_nil
        end # if
      end # if
      begin
        attributes[:protected] = protected_method_defined?(m)
        attributes[:private] = private_method_defined?(m)
        init_path << :protected
      rescue StandardError => exc
        init_path << :rescue_protected
      end # if
      init_path << if m.to_s[/[a-zA-Z0-9_]+/, 0] == m.to_s
                     :alphanumeric
                   else
                     :not_alphanumeric
                   end # if
      init_path
    end # init_path

    def method_query(m, class_of_receiver)
      ObjectSpace.each_object(class_of_receiver) do |object|
        next unless object.respond_to?(m.to_sym)
        begin
          theMethod = object.method(m.to_sym)
          return theMethod
        rescue ArgumentError, NameError => exc
          puts "exc=#{exc}, object=#{object.inspect}"
        end # begin
      end # each_object
      nil # no object found, new has side effects
    end # method_query

    def constantized
      @@CONSTANTIZED ||= Module.constants.map do |c|
        begin
           c = c.constantize
         rescue Exception => exception_object
         rescue
           puts "constant #{c.inspect} fails constanization" + exception_object.inspect
           nil
         end # begin
      end # map
    end # constantized
  end # ClassMethods
  extend ClassMethods
  include Virtus.value_object
  values do
    attribute :name, Symbol
    attribute :class_of_receiver, Class
    attribute :class_method, Object, default: true
    attribute :new_from_method, Method, default: nil
  end # values
  module Constructors # such as alternative new methods
    include DefinitionalConstants
    def new_from_method(method_object)
      if method_object.instance_of?(Class)
        MethodModel.new(name: method_object.name, class_of_receiver: method_object.owner.class, class_method: true, new_from_method: method_object)
      else
        MethodModel.new(name: method_object.name, class_of_receiver: method_object.owner, class_method: false, new_from_method: method_object)
    end # if
    end # new_from_method

    def class_ancestor_methods(object)
      instance = false
      if instance
        klass = object.class
        methods = klass.instance_methods(true)
      else
        klass = object
        methods = klass.methods(true)
      end # if

      models = methods.map do |method_name|
        ancestors = klass.ancestors.select do |ancestor|
          if instance
            ancestor.instance_methods(false).include?(method_name)
          else
            ancestor.methods(false).include?(method_name)
          end # if
        end # each
        ancestors.map do |ancestor|
          MethodModel.new(name: method_name, class_of_receiver: ancestor, class_method: !instance)
        end # map
      end # each
    end # class_ancestor_methods

    def matching_ancestors(klass, instance, method_name)
      ancestors = klass.ancestors.select do |ancestor|
        if instance
          ancestor.instance_methods(false).include?(method_name)
        else
          ancestor.methods(false).include?(method_name)
        end # if
      end # select
    end # matching_ancestors

    def method_inheritance(object, method_name)
      instance = !object.is_a?(Module)
      if instance
        klass = object.class
        methods = klass.instance_methods(true)
      else
        klass = object
        methods = klass.methods(true)
      end # if
      ancestors = klass.ancestors.select do |ancestor|
        if instance
          ancestor.instance_methods(false).include?(method_name)
        else
          ancestor.methods(false).include?(method_name)
        end # if
      end # each
      ancestors.map do |ancestor|
        MethodModel.new(name: method_name, class_of_receiver: ancestor, class_method: !instance)
      end # map
    end # method_inheritance

    def ancestor_methods(object)
      instance = !object.is_a?(Module)
      if instance
        klass = object.class
        methods = klass.instance_methods(true)
      else
        klass = object
        methods = klass.methods(true)
      end # if

      models = methods.map do |method_name|
        ancestors = klass.ancestors.select do |ancestor|
          if instance
            ancestor.instance_methods(false).include?(method_name)
          else
            ancestor.methods(false).include?(method_name)
          end # if
        end # each
        ancestors.map do |ancestor|
          MethodModel.new(name: method_name, class_of_receiver: ancestor, class_method: !instance)
        end # map
      end # each
      end # ancestor_methods
  end # Constructors
  extend Constructors

  module ReferenceObjects # constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
  end # ReferenceObjects
  include ReferenceObjects

  def inspect
    ret = @class_of_receiver.inspect
    ret += if @class_method
             '.'
           else
             '#'
        end # if
    ret += @name.to_s + ' is a '
    ret += if @class_method
             'class method of '
           else
             'instance method of '
        end # if
    ret += if @class_of_receiver.class == Class
             'class '
           else
             'module '
        end # if
    ret += @class_of_receiver.inspect
    unless @new_from_method.nil?
      ret += ' new_from_method = ' + @new_from_method.inspect
     end # if
    ret += "\n"
  end # inspect

  # include NoDB
  def theMethod
    if @class_method
      @class_of_receiver.method(@name.to_sym)
    else # look it up! Why? Beause can't create fully? Existence check?
      MethodModel.method_query(@name.to_sym, @class_of_receiver)
    end # if
  end # theMethod

  def source_location
    if theMethod.respond_to?(:source_location)
      theMethod.source_location
    end # if
  end # source_location

  def parameters
    if theMethod.respond_to?(:parameters)
      theMethod.parameters
    end # if
  end # parameters

  def find_example?(unit_class)
    examples = Example.find_by_class(unit_class, unit_class)
    if examples.empty?
      nil
    else
      examples.first
    end # if
  end # find_example?

  def make_executable_object(file_argument)
    if @unit_class.included_modules.include?(Virtus::InstanceMethods)
      @unit_class.new(executable: TestExecutable.new(executable_file: file_argument))
    else
      @unit_class.new(TestExecutable.new_from_path(file_argument))
    end # if
  end # make_executable_object

  def executable_object(file_argument = nil)
    example = find_example?
    if file_argument.nil?
      if example.nil? # default
        if number_of_arguments == 0
          make_executable_object($PROGRAM_NAME) # script file
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
    ret = if executable_object.respond_to?(method_name)
            method = executable_object.method(method_name)
          end # if
  end # executable_method?

  def method_exception_string(method_name)
    message = "#{method_name} is not an instance method of #{executable_object.class.inspect}"
    message += "\n candidate_commands = "
    message += candidate_commands_strings.join("\n")
    #		message += "\n\n executable_object.class.instance_methods = " + executable_object.class.instance_methods(false).inspect
  end # method_exception_string

  def arity(method_name)
    executable_method = executable_method?(method_name)
    ret = if executable_method.nil?
            message = "#{method_name} is not an instance method of #{executable_object.class.inspect}"
            message = candidate_commands_strings.join("\n")
            #		message += "\n candidate_commands = " + candidate_commands.inspect
            #		message += "\n\n executable_object.class.instance_methods = " + executable_object.class.instance_methods(false).inspect
            raise Exception.new(message)
          else
            executable_method.arity
    end # if
  end # arity

  def default_arguments?(method_name)
    if arity(method_name) < 0
      true
    else
      false
    end # if
    end # default_arguments

  def required_arguments(method_name)
    method_arity = arity(method_name)
    if default_arguments?(method_name)
      -(method_arity + 1)
    else
      method_arity
    end # if
  end # required_arguments

  require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
        #	asset_nested_and_included(:ClassMethods, self)
        #	asset_nested_and_included(:Constants, self)
        #	asset_nested_and_included(:Assertions, self)
        self
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
        self
      end # assert_post_conditions

      def assert_method_names(klass, selection = MethodModel::Default_ancestor_method_selection)
        selection = apply_selection_defaults(selection, MethodModel::Default_ancestor_method_selection)

        assert_operator(0, :<, klass.instance_methods(false).size)
        assert_equal(klass.instance_methods(false), MethodModel.method_names(klass))
        instance_methods = klass.instance_methods(false)
        assert_equal(instance_methods, MethodModel.method_names(klass))
        instance_methods = MethodModel.method_names(klass, selection)
        #		assert_equal({}, instance_methods) # debug

        ancestor_method_names = MethodModel.ancestor_method_names(klass, selection).values
        #		assert_equal({}, ancestor_method_names) # debug
        assert_instance_of(Array, instance_methods)
        assert_instance_of(Array, ancestor_method_names)
        missing_methods = instance_methods - ancestor_method_names.flatten
        assert_empty(missing_methods)
        extra_methods = ancestor_method_names.flatten - instance_methods
        assert_empty(extra_methods)
        assert_equal(instance_methods, ancestor_method_names.flatten)
        assert_equal(MethodModel.method_names(klass, selection), MethodModel.ancestor_method_names(klass, selection).values.flatten)
      end # method_names

      def assert_ancestors(klass, selection = MethodModel::Default_ancestor_method_selection)
        selection = apply_selection_defaults(selection, MethodModel::Default_ancestor_method_selection)

        assert_include(klass.ancestors, klass)
        assert_equal(klass.ancestors, MethodModel.ancestor_method_names(klass).keys)
        instance_methods = MethodModel.method_names(klass, selection)
        #		assert_equal({}, instance_methods) # debug

        ancestor_method_names = MethodModel.ancestor_method_names(klass, selection).values
        #		assert_equal({}, ancestor_method_names) # debug
        assert_instance_of(Array, instance_methods)
        assert_instance_of(Array, ancestor_method_names)
        missing_methods = instance_methods - ancestor_method_names.flatten
        assert_empty(missing_methods)
        extra_methods = ancestor_method_names.flatten - instance_methods
        extra_ancestors = {}
        extra_methods.each do |method_name|
          ancestors = MethodModel.ancestor_method_name(klass, method_name, selection).each do |ancestor|
            assert_instance_of(Class, ancestor)
            if extra_ancestors[ancestor].nil?
              extra_ancestors[ancestor] = [method_name]
            else
              extra_ancestors[ancestor] << method_name
            end # if
          end # each
        end # each
        message = 'ancestor_method_names returns extra methods not in methods(true).'
        message += "\n"
        message += extra_ancestors.inspect
        assert_empty(extra_ancestors, message)
      end # ancestors

      def assert_ancestor_method_names(klass, selection = MethodModel::Default_ancestor_method_selection)
        selection = apply_selection_defaults(selection, MethodModel::Default_ancestor_method_selection)

        assert_method_names(klass, selection)
        assert_ancestors(klass, selection)
      end # ancestor_method_names
    end # ClassMethods
    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
      if @class_method
        assert_respond_to(@class_of_receiver, @name)
        assert_include(@class_of_receiver.methods(true), @name, inspect)
        assert_include(@class_of_receiver.methods(false), @name, @class_of_receiver.methods(true))
      else
        #		assert_respond_to(@class_of_receiver, @name)
        assert_include(@class_of_receiver.instance_methods(false), @name)
      end # if
      self
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
      self
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  module Examples
    include DefinitionalConstants
    class EmptyClass
    end
    Instance_method_inspect = MethodModel.new(name: :inspect, class_of_receiver: MethodModel, class_method: false)
    Class_method_ancestor_methods = MethodModel.new(name: :ancestor_methods, class_of_receiver: MethodModel, class_method: true)
    Method_selections = [{ instance: true, method_name_selection: /.+/, include_inherited: false }
                  ].freeze
    Ancestor_method_selections = [{ instance: true, method_name_selection: /.+/, ancestor_selection: :ancestors },
                                  { instance: false },
                                  { method_name_selection: /instance_variable_.et/, include_inherited: true },
                                  { method_name_selection: /in/, include_inherited: true },
                                  { method_name_selection: /=/, include_inherited: true },
                                  { method_name_selection: /.+/, include_inherited: true }
                  ].freeze
  end # Examples
end # MethodModel

class Method
  module Examples
    Class_method_ancestor_methods = MethodModel.method(:ancestor_methods)
    Instance_method_inspect = MethodModel::Examples::Instance_method_inspect.method(:inspect)
  end # Examples
end # Method

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
    # include DefinitionalConstants
    Method_arity = MethodModel.new(name: :arity, class_of_receiver: Method, class_method: false)
    Method_require1 = MethodModel.new(name: :require1, class_of_receiver: Example, class_method: false)
    Method_require2 = MethodModel.new(name: :require2, class_of_receiver: Example, class_method: false)
    Method_require3 = MethodModel.new(name: :require3, class_of_receiver: Example, class_method: false)
    Method_all_default = MethodModel.new(name: :all_default, class_of_receiver: Example, class_method: false)
  end # Examples
end # Example

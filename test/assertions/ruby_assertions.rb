###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'pathname'
require_relative '../../app/models/global.rb'
require 'set'
# add introspective for default error_messages
class Object
  def default_message
    message = "\n self=#{inspect}\n"
    message += "\n instance_variables=#{instance_variables.inspect}"
  end # default_message

  def caller_lines(ignore_lines = 19)
    "\n#{caller[0..-ignore_lines].join("\n")}\n"
  end # caller_lines
end # Object

class Module
  def default_message
    message = "\nModule.nesting=#{Module.nesting.inspect}"
    message += "\n Class #{self.class.name}"
    name_list_method = :included_modules
  end # default_message
end # Module

class Method
end # Method

module Kernel
  # Default message if message is empty
  def add_default_message(message = '')
    if message == ''
      default_message
    else
      message
    end # if
  end # add_default_message

  def newline_if_not_empty(message)
    if message.empty?
      message
    else
      message + "\n"
    end # if
  end # newline_if_not_empty

  def trace_value(value, name = nil)
  end # trace_value

  def trace_to_s(expression_string)
    "\n" + expression_string.to_s + ' = ' + eval(expression_string.to_s)
  end # trace_to_s

  def trace(expression_string)
    "\n" + expression_string.to_s + '.inspect = ' + eval(expression_string.to_s).inspect
  end # trace

  def trace_names?(name_list_method = :instance_variables)
    name_list = method(name_list_method).call
    name_list.map do |name|
      trace(name)
    end # map
  end # trace_names?

  def default_message
    message = "\nModule.nesting=#{Module.nesting.inspect}"
    message += "\n Class #{self.class.name}"
    message += ' unknown method'
    message += "\n self=#{inspect}\n"
    message += "\n local_variables=#{local_variables.inspect}"
    message += "\n instance_variables=#{instance_variables.inspect}"
    #	message+=" callers=#{caller_lines}"
    message
  end # default_message
end # Kernel

module RubyAssertions
# include AssertionsModule
# extend AssertionsModule
# returns to ruby 1.8 behavior
=begin
def build_message(head, template=nil, *arguments)
#  head=head+", arguments=#{arguments.inspect}"
  template &&= template.chomp
  arguments.each do |arg|
    template.sub!(/\?/, arg.inspect)
  end #each
  caller_lines+head.to_s+template
end
def assert(test, msg = UNASSIGNED)
  case msg
  when UNASSIGNED
    msg = nil
  when String, Proc
  else
    bt = caller.reject { |s| s.rindex(MINI_DIR, 0) }
    raise ArgumentError, "assertion message must be String or Proc, but #{msg.class} was given.", bt
  end
  super caller_lines+msg.to_s
end
=end
  def warn(message = '')
    unless $VERBOSE.nil?
      $stdout.puts message
    end # if
    if block_given?
      begin
        yield
      rescue Exception => exception_raised
        puts exception_raised.inspect
      rescue String => exception_raised
        puts MiniTest::Assertion_raised.inspect
      end # begin
    end # if
  end # warn

  def info(message)
    if $VERBOSE
      $stdout.puts message
    end # if
  end # info

  # make requires quieter by supressing debug logging
  def quieter
    old_verbose = $VERBOSE
    $VERBOSE = case
               when nil then nil
               when false then nil
               when true then false
    end # case
    if block_given?
      begin
        yield
      rescue Exception => exception_raised
        puts exception_raised.inspect
      rescue String => exception_raised
        puts MiniTest::Assertion_raised.inspect
      end # begin
    end # if
    $VERBOSE = old_verbose
  end # quieter
  # File of ruby assertions not requiring ActiveRecord or fixtures

  def assert_call_result(obj, methodName, *arguments)
    assert_instance_of(Symbol, methodName, "assert_call_result caller=#{caller.inspect}")
    explain_assert_respond_to(obj, methodName)
    m = obj.method(methodName)
    m.call(*arguments)
  end # assert_call_result

  def assert_call(obj, methodName, *arguments)
    result = assert_call_result(obj, methodName, *arguments)
    refute_nil(result)
    message = "\n#{obj.canonicalName}.#{methodName}(#{arguments.collect(&:inspect).join(',')}) returned no data. result.inspect=#{result.inspect}; obj.inspect=#{obj.inspect}"
    if result.instance_of?(Array)
      assert_operator(result.size, :>, 0, message)
    elsif result.instance_of?(String)
      assert_operator(result.length, :>, 0, message)
    elsif result.is_a?(Acquisition)
      assert(!result.acquisition_data.empty? || !result.error.empty?)
    end
    result
  end # assert_call

  def assert_answer(obj, methodName, answer, *arguments)
    result = assert_call_result(obj, methodName, *arguments)
    assert_equal(answer, result)
    result
  end # assert_answer

  def explain_assert_equal(expected, actual, context = nil)
    message = build_message(context, 'actual and expected convert to_s differently (why are you calling the explain version).')
    assert_equal(expected.to_s, actual.to_s, message)
    message = build_message(context, 'actual and expected convert to_s the same, but inspect differently (perhaps diffent classes).')
    assert_equal(expected.inspect, actual.inspect, message)
    message = build_message(context, 'actual and expected have different class names')
    assert_equal(expected.class.name, actual.class.name, message)
    message = build_message(context, 'actual and expected are different classes even though they have the same class names (is this even possible?).')
    assert_equal(expected.class, actual.class, message)
    message = build_message(context, 'actual and expected are different, even though both text representations (to_s and inspect)are identical ()diiferent addresses or hashes?.')
    assert_equal(expected, actual, message)
  end # explain_assert_equal

  # needed to get past to_s bug
  def explain_assert(message = 'assert failed.') # :yields:
    _wrap_assertion do
      if message.instance_of?(String)
        exception = message.to_s
      elsif message.instance_of?(Test::Unit::Assertions::AssertionMessage)
        exception = 'how do I get past to_s bug?'
      else
        message = "assert failed. message.class=#{message.class}"
        exception = message.to_s
      end # if
      unless yield
        raise exception
        raise message.to_s
        raise AssertionFailedError.new(message.to_s)
      end
    end
  end # explain_assert

  def explain_assert_respond_to(obj, methodName, message = '')
    refute_nil(obj, "explain_assert_respond_to can\'t do much with a nil object.")
    assert_respond_to(methodName, :to_s, 'methodName must be of a type that supports a to_s method.')
    assert(!methodName.to_s.empty?, "methodName=\"#{methodName}\" must not be a empty string")
    message1 = message + "Object #{obj.canonicalName} of class='#{obj.class}' does not respond to method :#{methodName}"
    if obj.instance_of?(Class)
      if obj.instance_methods(true).include?(methodName.to_s)
        message = "It's an instance, not a class method."
      else
        if obj.instance_methods(false).empty?
          message = "#{message1}; has no noninherited class methods."
        else
          message = "#{message1}; noninherited instance methods= #{obj.instance_methods(false).inspect}"
        end # if
      end # if
      assert_respond_to(obj, methodName, message)
    elsif obj.instance_of?(Module)
      if obj.instance_methods(true).include?(methodName.to_s)
        message = "It's an instance method of module #{obj.name}. Other instance methods=#{obj.instance_methods.inspect}"
      else
        if obj.instance_methods(false).empty?
          message = "#{message1}; has no noninherited class methods."
        else
          message = "#{message1}; noninherited class methods= #{obj.instance_methods(false).inspect}"
             end # if
       end # if
      assert_respond_to(obj, methodName, message)
    else # not Class, Module. Instance?
      # warn		noninherited=obj.class.public_instance_methods-obj.class.superclass.public_instance_methods
      #		assert_equal(obj.class.public_instance_methods,obj.public_class_methods)
      if obj.respond_to?(methodName.to_s)
        return # OK not ActiveRecord
      # ~ elsif obj.activeRecordTableNotCreatedYet?(obj) then
      # ~ message="#{message1}; noninherited instance methods= #{obj.noninherited_public_instance_methods(obj).inspect}"
      else
        message = "#{message1}; noninherited instance methods= #{obj.noninherited_public_instance_methods.inspect}"
        message = " obj.class.included_modules=#{obj.class.included_modules.inspect}"
        assert_respond_to(obj, methodName, message)
          end
     end
end # explain_assert_respond_to

  # def refute_empty(object,message='')
  #	puts "in refute_empty: message=#{message.inspect}"
  #	message+="\n#{object.canonicalName}, is empty with value #{object.inspect}."
  #	refute_nil(object,message)
  #	assert(!object.empty?, message)
  # end #refute_empty
  # def assert_empty(object,message='')
  #	message = newline_if_not_empty(message) + object.inspect + " is not empty."
  #	if !object.nil?  then # nil is empty
  #		assert(object.empty? || object==Set[nil]}
  #	end #if
  # end #assert_empty
  def assert_flat_set(set)
    set.to_a.each do |e|
      assert(!e.instance_of?(Set))
    end
  end # assert_flat_set

  def assert_set_promotable(enumeration)
  end # assert_set_promotable

  def assert_subset(subset_enumeration, superset_enumeration, _message = '')
    if subset_enumeration.instance_of?(Set)
      subset = subset_enumeration
    else
      subset_enumeration_array = subset_enumeration.to_a.map(&:to_s)
      #		expected_set=Set.new subset_enumeration_array
      subset = subset_enumeration_array.to_set
  end # if
    superset = if superset_enumeration.instance_of?(Set)
                 superset_enumeration
               else
                 Set.new(superset_enumeration.to_a.map(&:to_s))
  end # if
    assert_flat_set(subset)
    assert_flat_set(superset)
    subset_surplus = subset - superset
    assert_empty(subset_surplus, "subset_surplus=#{subset_surplus}, superset=#{superset}, subset=#{subset}")
end # assert_subset

  def assert_equal_sets(expected_enumeration, actual_enumeration, message = '')
    expected_set = if expected_enumeration.instance_of?(Set)
                     expected_enumeration
                   else
                     Set.new(expected_enumeration.to_a.map(&:to_s))
                   end # if
    actual_set = if actual_enumeration.instance_of?(Set)
                   actual_enumeration
                 else
                   Set.new(actual_enumeration.to_a.map(&:to_s))
  end # if
    assert_flat_set(expected_set)
    assert_flat_set(actual_set)
    #	actual_set=Set[actual_enumeration.to_a.map {|e| e.to_s}]
    expected_extras = expected_set - actual_set
    actual_extras = actual_set - expected_set
    if expected_extras.empty?
      message = build_message(message, message = 'expected is a subset of actual')
    else
      message = build_message(message, ' ? is in expected set but not actual set.', expected_extras.set_inspect)
  end
    if actual_extras.empty?
      message = message = build_message(message, 'actual is a subset of expected')
    else
      message = build_message(message, ' ? is in actual set but not expected set.', actual_extras.set_inspect)
  end
    if expected_set != actual_set

      message = build_message(message, ' expected idenities= ? but actual idenities= ? .', expected_set.set_inspect, actual_set.set_inspect)
      raise message.to_s
      assert_equal(expected_set, actual_set, message)
  end # if
  end # assert_equal_sets

  def assert_overlap(enum1, enum2)
    refute_empty(enum1, 'Assume first set to not be empty.')
    refute_empty(enum2, 'Assume second set to not be empty.')
    assert("enum1=#{enum1.inspect} does not overlap enum2=#{enum2.inspect}") { !(enum1 & enum2).empty? }
  end # assert_overlap

  # def assert_includes(list, element,  message = '')
  #	message = "First argument of assert_include must be an Array or Set"
  #	message += ', not ' + list.inspect
  #	fail message if !(list.instance_of?(Array) || list.instance_of?(Set))
  #	message = message + element.inspect
  #	message += " is not in list " + list.inspect
  #	assert(list.include?(element),message)
  # end #assert_include
  def assert_dir_includes(filename, glob)
    assert_includes(Dir[glob], filename, "Dir['#{glob}']=#{Dir[glob]} does not include #{filename}.")
  end # assert_dir_include

  # def refute_includes(list, element,  message = '')
  #	message=build_message(message, "? is in list ?", element,list)
  #	assert(!list.include?(element)}
  # end #refute_include
  def assert_public_instance_method(obj, methodName, message = '')
    # noninherited=obj.class.public_instance_methods-obj.class.superclass.public_instance_methods
    if obj.respond_to?(methodName)
      message += 'expect to pass'
      #	elsif obj.respond_to?(methodName.to_s.singularize) then
      #		message+="but singular #{methodName.to_s.singularize} is a method"
      #	elsif obj.respond_to?(methodName.to_s.pluralize) then
      #		message+="but plural #{methodName.to_s.pluralize} is a method"
      #	elsif obj.respond_to?(methodName.to_s.tableize) then
      #		message+="but tableize #{methodName.to_s.tableize} is a method"
      #	elsif obj.respond_to?(methodName.to_s.tableize.singularize) then
      #		message+="but singular tableize #{methodName.to_s.tableize.singularize} is a method"
      #	else
      #		message+="but neither singular #{methodName.to_s.singularize} nor plural #{methodName.to_s.pluralize} nor tableize #{methodName.to_s.tableize} nor singular tableize #{methodName.to_s.tableize.singularize} is a method"
    end # if
    assert_respond_to(obj, methodName, message)
  end # assert_public_instance_method

  def assert_array_of(obj, type)
    assert("obj=#{obj.inspect} must be an Array not #{obj.class.name}") { obj.instance_of?(Array) }
    obj.each do |_p|
      #		puts "p=#{p.inspect} must be a String(pathnames)"
      assert("obj=#{obj.inspect} must be an Array of #{type.name}") { obj.all? { |s| s.instance_of?(type) } }
    end # each
  end # array_of

  def assert_no_duplicates(array, columns_to_ignore = [])
    assert_operator(array.uniq.size, :>, 1, 'All input array elements are identical')
    assert_operator(array.size / array.uniq.size, :<, 1.2, "Array has too many duplicates. First ten elements are #{array[0..9]}" + caller_lines)
    if array[0].instance_of?(Hash) && columns_to_ignore != []
      array = array.map { |hash| columns_to_ignore.each { |col| hash.delete(col) } }
  end # if
    assert_operator(array.uniq.size, :>, 1, "All ignored array elements are identical=#{array.uniq.inspect}")
    frequencies = {}
    array.sort { |a1, a2| a1.inspect <=> a2.inspect }.chunk { |hash| hash }.map { |key, ary| frequencies[key] = ary.size }
    assert_instance_of(Hash, frequencies, frequencies.inspect)
    sorted_by_frequency = frequencies.to_a.sort { |x, y| x[1] <=> y[1] }
    message = "Array has duplicates. First ten most common elements are #{sorted_by_frequency[-10..-1]}" + caller_lines
    #	message+="frequencies.inspect[0..100]=#{frequencies.inspect[0..100]}"
    assert_equal(array.size, array.uniq.size, message)
  end # assert_no_duplicates

  def assert_single_element_array(obj)
    assert_instance_of(Array, obj, 'assert_single_element_array expects an Array. ')
    assert_equal(1, obj.size)
  end # assert_single_element_array

  # assert regexp is properly formatted
  def assert_regexp(regexp)
    Regexp.new(regexp)
  rescue RegexpError => exception
    assert("regexp=#{regexp.inspect}, exception=#{exception.inspect}") { false }
  end # assert_regexp

  def assert_attribute_of(obj, symbol, type)
    assert(obj[symbol].instance_of?(type), "obj[:#{symbol}]=#{obj[symbol].inspect} must be of type #{type}, but is of type #{obj[symbol].class} obj=#{obj.inspect}")
  end # assert_attribute_of

  def assert_has_instance_methods(model_class, message = '')
    message = build_message(message, '? has no public instance methods.', model_class.canonicalName)
    assert(!model_class.instance_methods(false).empty?, message)
  end # assert_has_instance_methods

  def assert_module_included(klass, moduleName)
    # The assertion upon which all other assertions are based. Passes if the block yields true.
    assert(klass.module_included?(moduleName), "Module #{moduleName} not included in #{klass.canonicalName} context.Modules actually included=#{klass.ancestors.inspect}. klass.module_included?(moduleName)=#{klass.module_included?(moduleName)}")
  end # assert_module_included

  def global_name?(name)
    Module.constants.include?(name)
  end # global_name

  def assert_global_name(name)
    assert_includes(Module.constants, name)
  end # global_name

  def assert_scope_path(*names)
    return [] if names.empty?
    refute_empty(names, 'Expect non-empty scope path.')
    unless global_name?(names[0])
      names = [self.class.name.to_sym] + names
    #		puts "after adding self, names=#{names.inspect}"
  end # if
    names.each_index do |i|
      if i == 0
        assert_includes(Module.constants, names[i], 'Global constants should be in Module.constants')
      else
        testRange = 0..(i - 1)
        #	puts "testRange=#{testRange.inspect}"
        assert_instance_of(Symbol, names[i], "names[#{i}]=#{names[i].inspect},testRange=#{testRange}")
        #	puts "names[testRange]=#{names[testRange].inspect}"
        path = names[testRange].join('::')
        message = 'assert_scope_path: '
        message += " names=#{names.inspect}"
        message += " testRange=#{testRange.inspect}, path=#{path.inspect}"
        message += " path=#{path.inspect}"
        #		message += trace_names?(:names)
        #		message += trace('names')
        begin
          object = eval(path)
          refute_nil(object, message)
          assert_kind_of(Module, object, message)
          assert_includes(object.constants, names[i], names[i].to_s + ' is not a constant in module ' + path)
        end # begin
       end # if
    end # each_index
    names # with inserted local module
  end # assert_scope_path

  def assert_path_to_constant(*names)
    context = assert_scope_path(*names[0..-2]) # splat
    constant_name = names[-1..-1]
    names = context + constant_name
    path = names.join('::')
    message = "names=#{names.inspect}, path=#{path.inspect}"
    begin
      object = eval(path)
    rescue
      raise message
    end # begin
    refute_nil(object)
  end # assert_path_to_constant

  def assert_constant_path_respond_to(*names)
    if names.size < 2
      raise "In assert_path_to_method: Not enough arguments. names=#{names.inspect}"
    elsif names.size == 2 # local object
      if instance_variables.include?(names[0])
        explain_assert_respond_to(eval(names[0]), names[1])
      end # if
    else
      context = assert_scope_path(*names[0..-2])
      path = eval(context.join('::'))
      method_name = names[-1]
      message = "names=#{names.inspect}, path=#{path.inspect}"
      explain_assert_respond_to(path, method_name, message)
    end #
  end # assert_constant_path_respond_to

  def assert_constant_instance_respond_to(*names)
    if names.size < 2
      raise "In assert_path_to_method: Not enough arguments. names=#{names.inspect}"
    elsif names.size == 2 # local object
      if instance_variables.include?(names[0])
        assert_public_instance_method(eval(names[0]), names[1])
      end # if
    else
      context = assert_scope_path(*names[0..-2])
      path = eval(context.join('::'))
      method_name = names[-1]
      message = "names=#{names.inspect}, path=#{path.inspect}"
      assert_public_instance_method(path, method_name, message)
    end #
  end # assert_constant_instance_respond_to

  def missing_file_message(pathname)
    if pathname.nil?
      "Pathname passed is nil in  missing_file_message.\n" + caller[0..-1].join("\n")
    else
      pathname = Pathname.new(pathname).expand_path
      if pathname.exist?
        ''
      else
        existing_dir = nil
        pathname.ascend { |f| (existing_dir = f) && break if f.exist? }
        'pathname = ' + pathname.to_s + " does not exist\n" \
    		'parent directory ' +
          existing_dir.to_s +
          ' does exists containing ' +
          Dir[existing_dir.to_s + '*'].map { |f| File.basename(f) }.inspect
      end # if
    end # if
    end # missing_file_message

  def assert_pathname_exists(pathname, message = '')
    message = missing_file_message(pathname.to_s) + message
    refute_nil(pathname, message)
    refute_empty(pathname.to_s, message + 'Assume pathname to not be empty.')
    pathname = Pathname.new(pathname).expand_path
    message += "\nPathname(#{pathname}).exist?=" + pathname.exist?.to_s + "\n" + missing_file_message(pathname)
    assert(pathname.exist?, message)
    assert(File.exist?(pathname), message + "File.exists?(#{pathname})=#{File.exist?(pathname).inspect}")
    pathname # allow chaining
  end # assert_pathname_exists

  def assert_directory_exists(pathname, message = '')
    pathname = assert_pathname_exists(pathname, message)
    ftype = File.ftype(pathname).to_sym
    if ftype == :link
      symlink = File.readlink(pathname)
      expanded = File.expand_path(symlink, File.dirname(pathname))
      refute_equal(pathname, symlink, 'recursion problem: ' + message)
      assert_directory_exists(symlink)
    else
      assert_equal(ftype, :directory, message + "File.ftype(#{pathname})=#{File.ftype(pathname).inspect}")
    end # if
    pathname # allow chaining
  end # assert_directory_exists

  def assert_data_file(pathname, message = '')
    message += 'pathname = ' + "'" + pathname.to_s + "'"
    assert_pathname_exists(pathname, message)
    assert(File.file?(pathname), "File.file?(#{pathname})=#{File.file?(pathname).inspect}, is it a directory?")
    refute_nil(File.size?(pathname), message)
    refute_equal(0, File.size?(pathname), message)
    pathname # allow chaining
  end # assert_data_file

  def nested_scope_modules?
    nested_constants = self.class.constants
    message = ''
    assert_includes(included_modules.map(&:name), :Assertions, message)
    assert_equal([:Constants, :Assertions, :ClassMethods], Version.nested_scope_modules?)
  end # nested_scopes

  def assert_nested_scope_submodule(_module_symbol, context = self, message = '')
    message += "\nIn assert_nested_scope_submodule for class #{context.name}, "
    message += "make sure module Constants is nested in #{context.class.name.downcase} #{context.name}"
    message += " but not in #{context.nested_scope_modules?.inspect}"
    assert_includes(constants, :Contants, message)
end # assert_included_submodule

  def assert_included_submodule(_module_symbol, _context = self, message = '')
    message += "\nIn assert_included_submodule for class #{name}, "
    message += "make sure module Constants is nested in #{self.class.name.downcase} #{name}"
    message += " but not in #{nested_scope_modules?.inspect}"
    assert_includes(included_modules, :Contants, message)
end # assert_included_submodule

  def assert_nested_and_included(module_symbol, _context = self, _message = '')
    assert_nested_scope_submodule(module_symbol)
    assert_included_submodule(module_symbol)
end # assert_nested_and_included
end # RubyAssertions
# include Test::Unit::Assertions
# Test::Unit::Assertions.assert_pre_conditions

###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit'
require_relative '../../app/models/global.rb'
require 'set'
module Test
module Unit
module Assertions
def caller_lines(ignore_lines=19)
	"\n#{caller[0..-ignore_lines].join("\n")}\n"
end #caller_lines
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
def warn(message='', &block)
	if !$VERBOSE.nil? then
		$stdout.puts message
	end #if
  if block_given? then
    begin
      block.call
    rescue Exception => exception_raised
      puts exception_raised.inspect
    rescue String => exception_raised
      puts MiniTest::Assertion_raised.inspect
    end #begin
  end #if
end #warn
def info(message)
	if $VERBOSE then
		$stdout.puts message
	end #if
end #info     
def default_message
	message="Module.nesting=#{Module.nesting.inspect}"
	message+=" Class #{self.class.name}"
	message+=" unknown method"
	message+=" self=#{self.inspect}"
	message+=" local_variables=#{local_variables.inspect}"
	message+=" instance_variables=#{instance_variables.inspect}"
	message+=" callers=#{caller_lines}"
	return message
end #default_message
# File of ruby assertions not requiring ActiveRecord or fixtures

def assert_call_result(obj,methodName,*arguments)
	assert_instance_of(Symbol,methodName,"assert_call_result caller=#{caller.inspect}")
	explain_assert_respond_to(obj,methodName)
	m=obj.method(methodName)
	return m.call(*arguments)
end #assert_call_result
def assert_call(obj,methodName,*arguments)
	result=assert_call_result(obj,methodName,*arguments)
	assert_not_nil(result)
	message="\n#{obj.canonicalName}.#{methodName}(#{arguments.collect {|arg|arg.inspect}.join(',')}) returned no data. result.inspect=#{result.inspect}; obj.inspect=#{obj.inspect}"
	if result.instance_of?(Array) then
		assert_operator(result.size,:>,0,message)
	elsif result.instance_of?(String) then
		assert_operator(result.length,:>,0,message)
	elsif result.kind_of?(Acquisition) then
		assert(!result.acquisition_data.empty? || !result.error.empty?) 
	end
	return result
end #assert_call
def assert_answer(obj,methodName,answer,*arguments)
	result=assert_call_result(obj,methodName,*arguments)	
	assert_equal(answer,result)
	return result
end #assert_answer
def explain_assert_equal(expected, actual, context=nil)
	message=build_message(context, "actual and expected convert to_s differently (why are you calling the explain version).")
	assert_equal(expected.to_s, actual.to_s, message)
	message=build_message(context, "actual and expected convert to_s the same, but inspect differently (perhaps diffent classes).")
	assert_equal(expected.inspect, actual.inspect, message)
	message=build_message(context, "actual and expected have different class names")
	assert_equal(expected.class.name, actual.class.name, message)
	message=build_message(context, "actual and expected are different classes even though they have the same class names (is this even possible\?).")
	assert_equal(expected.class, actual.class, message)
	message=build_message(context, "actual and expected are different, even though both text representations (to_s and inspect)are identical ()diiferent addresses or hashes\?.")
	assert_equal(expected, actual, message)
end #explain_assert_equal
# needed to get past to_s bug
def explain_assert_block(message="assert_block failed.") # :yields: 
  _wrap_assertion do
  if message.instance_of?(String) then
    exception=message.to_s
  elsif message.instance_of?(Test::Unit::Assertions::AssertionMessage) then
    exception='how do I get past to_s bug?'	
  else
    message="assert_block failed. message.class=#{message.class}"
    exception=message.to_s
  end #if
    if (! yield)
      raise exception
      raise message.to_s
      raise AssertionFailedError.new(message.to_s)
    end
  end
end #explain_assert_block
def explain_assert_respond_to(obj,methodName,message='')
	assert_not_nil(obj,"explain_assert_respond_to can\'t do much with a nil object.")
	assert_respond_to(methodName,:to_s,"methodName must be of a type that supports a to_s method.")
	assert(methodName.to_s.length>0,"methodName=\"#{methodName}\" must not be a empty string")
	message1=message+"Object #{obj.canonicalName} of class='#{obj.class}' does not respond to method :#{methodName}"
	if obj.instance_of?(Class) then
		if obj.instance_methods(true).include?(methodName.to_s) then
			message= "It's an instance, not a class method."
		else
			if obj.instance_methods(false).empty? then
				message="#{message1}; has no noninherited class methods."
			else
				message="#{message1}; noninherited instance methods= #{obj.instance_methods(false).inspect}"
			end #if
		end #if
		assert_respond_to(obj,methodName,message)
	elsif obj.instance_of?(Module) then
		if obj.instance_methods(true).include?(methodName.to_s) then
			message= "It's an instance method of module #{obj.name}. Other instance methods=#{obj.instance_methods.inspect}"
		else
			if obj.instance_methods(false).empty? then
				message="#{message1}; has no noninherited class methods."
			else
				message="#{message1}; noninherited class methods= #{obj.instance_methods(false).inspect}"
			end #if
		end #if
		assert_respond_to(obj,methodName,message)
	else # not Class, Module. Instance?
#warn		noninherited=obj.class.public_instance_methods-obj.class.superclass.public_instance_methods
#		assert_equal(obj.class.public_instance_methods,obj.public_class_methods)
		if obj.respond_to?(methodName.to_s) then
			return # OK not ActiveRecord
		#~ elsif obj.activeRecordTableNotCreatedYet?(obj) then
			#~ message="#{message1}; noninherited instance methods= #{obj.noninherited_public_instance_methods(obj).inspect}"
		else
			message="#{message1}; noninherited instance methods= #{obj.noninherited_public_instance_methods.inspect}"
			message=" obj.class.included_modules=#{obj.class.included_modules.inspect}"
			assert_respond_to(obj,methodName,message)
		end
	end
end #explain_assert_respond_to
def assert_not_empty(object,message='')
#	puts "in assert_not_empty: message=#{message.inspect}"
	message+="\n#{object.canonicalName}, is empty with value #{object.inspect}."
	assert_not_nil(object,message)
	assert_block(message){!object.empty?}
end #assert_not_empty
def assert_empty(object,message='')
	message+=object.canonicalName+" is not empty but contains "+object.inspect  
	if !object.nil?  then # nil is empty
		assert_block(message){object.empty? || object==Set[nil]}
	end #if
end #assert_empty
def assert_flat_set(set)
	set.to_a.each do |e|
		assert(!e.instance_of?(Set))
	end
end #assert_flat_set
def assert_set_promotable(enumeration)
end #assert_set_promotable
def assert_subset(subset_enumeration, superset_enumeration, message=nil)
	if subset_enumeration.instance_of?(Set) then
		subset=subset_enumeration
	else
		subset_enumeration_array=subset_enumeration.to_a.map {|e| e.to_s}
#		expected_set=Set.new subset_enumeration_array
		subset=subset_enumeration_array.to_set
	end #if
	if superset_enumeration.instance_of?(Set) then
		superset=superset_enumeration
	else
		superset=Set.new(superset_enumeration.to_a.map {|e| e.to_s})
	end #if
	assert_flat_set(subset)
	assert_flat_set(superset)
	subset_surplus=subset-superset
	assert_empty(subset_surplus, "subset_surplus=#{subset_surplus}, superset=#{superset}, subset=#{subset}")
end #assert_subset
def assert_equal_sets(expected_enumeration,actual_enumeration,message=nil)
	if expected_enumeration.instance_of?(Set) then
		expected_set=expected_enumeration
	else
		expected_set=Set.new(expected_enumeration.to_a.map {|e| e.to_s})
	end #if
	if actual_enumeration.instance_of?(Set) then
		actual_set=actual_enumeration
	else
		actual_set=Set.new(actual_enumeration.to_a.map {|e| e.to_s})
	end #if
	assert_flat_set(expected_set)
	assert_flat_set(actual_set)
#	actual_set=Set[actual_enumeration.to_a.map {|e| e.to_s}]
	expected_extras=expected_set-actual_set
	actual_extras=actual_set-expected_set
	if expected_extras.empty? then
		message=build_message(message, message="expected is a subset of actual")
	else
		message=build_message(message, " ? is in expected set but not actual set.", expected_extras.set_inspect)   
	end
	if actual_extras.empty? then
		message=message=build_message(message, "actual is a subset of expected")
	else
		message=build_message(message, " ? is in actual set but not expected set.", actual_extras.set_inspect)   
	end
	if expected_set!=actual_set then
		
		message=build_message(message, " expected idenities= ? but actual idenities= ? .", expected_set.set_inspect, actual_set.set_inspect)
		raise "#{message}"
		assert_equal(expected_set,actual_set,message)
	end #if
end #assert_equal_sets
def assert_overlap(enum1,enum2)
	assert_not_empty(enum1, "Assume first set to not be empty.")
	assert_not_empty(enum2, "Assume second set to not be empty.")
	assert_block("enum1=#{enum1.inspect} does not overlap enum2=#{enum2.inspect}"){!(enum1&enum2).empty?}
end #assert_overlap
#def assert_include(element,list,message=nil)
#	raise "Second argument of assert_include must be an Array or Set" if !(list.instance_of?(Array) || list.instance_of?(Set))
#	if message.nil? then
#		message=build_message(message, "? is not in list ?", element,list.inspect)
#	end #if 
#	assert(list.include?(element),message)
#end #assert_include
def assert_dir_include(filename,glob)
	assert_include(Dir[glob], filename, "Dir['#{glob}']=#{Dir[glob]} does not include #{filename}.")
end #assert_dir_include
#def assert_not_include(list, element, message=nil)
#	message=build_message(message, "? is in list ?", element,list)   
#	assert_block(message){!list.include?(element)}
#end #assert_not_include
def assert_public_instance_method(obj,methodName,message='')
	#noninherited=obj.class.public_instance_methods-obj.class.superclass.public_instance_methods
	if obj.respond_to?(methodName) then
		message+='expect to pass'
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
	end #if
	assert_respond_to( obj, methodName,message)
end #assert_public_instance_method
def assert_array_of(obj, type)
	assert_block("obj=#{obj.inspect} must be an Array not #{obj.class.name}") {obj.instance_of?(Array)}
	obj.each do |p|
#		puts "p=#{p.inspect} must be a String(pathnames)" 
		assert_block("obj=#{obj.inspect} must be an Array of #{type.name}") {obj.all?{|s| s.instance_of?(type)}}
	end #each
end #array_of
def assert_no_duplicates(array, columns_to_ignore=[])
	assert_operator(array.uniq.size, :>, 1, "All input array elements are identical")
	assert_operator(array.size/array.uniq.size, :<, 1.2, "Array has too many duplicates. First ten elements are #{array[0..9]}"+caller_lines)
	if array[0].instance_of?(Hash) and columns_to_ignore!=[] then
		array=array.map {|hash| columns_to_ignore.each{|col| hash.delete(col)}}
	end #if
	assert_operator(array.uniq.size, :>, 1, "All ignored array elements are identical=#{array.uniq.inspect}")
	frequencies={}
	array.sort{|a1,a2| a1.inspect<=>a2.inspect}.chunk{|hash| hash}.map{|key, ary|frequencies[key]=ary.size}
	assert_instance_of(Hash, frequencies, frequencies.inspect)
	sorted_by_frequency=frequencies.to_a.sort{|x,y| x[1]<=>y[1]}
	message="frequencies.inspect[0..100]=#{frequencies.inspect[0..100]}"
	message+="Array has duplicates. First ten most common elements are #{sorted_by_frequency[0..10]}"+caller_lines
	assert_equal(array.size, array.uniq.size, message)
end #assert_no_duplicates
def assert_single_element_array(obj)
	assert_instance_of(Array, obj, "assert_single_element_array expects an Array. ")
	assert_equal(1, obj.size)
end #assert_single_element_array
# assert regexp is properly formatted
def assert_regexp(regexp)
	Regexp.new(regexp)
rescue RegexpError => exception
	assert_block("regexp=#{regexp.inspect}, exception=#{exception.inspect}"){false}
end #assert_regexp
def assert_attribute_of(obj, symbol, type)
	assert_block("obj[:#{symbol}]=#{obj[symbol].inspect} must be of type #{type}, but is of type #{obj[symbol].class} obj=#{obj.inspect}") {obj[symbol].instance_of?(type)}
end #assert_attribute_of

def assert_has_instance_methods(model_class,message=nil)
	message=build_message(message, "? has no public instance methods.", model_class.canonicalName)   
	assert_block(message){!model_class.instance_methods(false).empty?}
end #assert_has_instance_methods
def assert_module_included(klass,moduleName)
#The assertion upon which all other assertions are based. Passes if the block yields true.
	assert_block "Module #{moduleName} not included in #{klass.canonicalName} context.Modules actually included=#{klass.ancestors.inspect}. klass.module_included?(moduleName)=#{klass.module_included?(moduleName)}" do
    		klass.module_included?(moduleName)
	end #assert_block
end #assert_module_included
def global_name?(name)
	Module.constants.include?(name)
end #global_name
def assert_global_name(name)
	assert_include(Module.constants, name)
end #global_name
def assert_scope_path(*names)
	return [] if names.size==0
	assert_not_empty(names, "Expect non-empty scope path.")
	if !global_name?(names[0]) then
		names=[self.class.name.to_sym]+names
#		puts "after adding self, names=#{names.inspect}"
	end #if
	names.each_index do |i|
		testRange=0..i
	#	puts "testRange=#{testRange.inspect}"
		assert_instance_of(Symbol, names[i], "names[#{i}]=#{names[i].inspect},testRange=#{testRange}")
	#	puts "names[testRange]=#{names[testRange].inspect}"
		path=names[testRange].join('::')
		message="assert_scope_path: names=#{names.inspect}, testRange=#{testRange.inspect}, path=#{path.inspect}"
		begin
			object=eval(path)
		rescue
			fail message
		end #begin
		assert_not_nil(object, message)
		assert_kind_of(Module, object, message)
	end#if
	return names # with inserted local module
end #assert_scope_path
def assert_path_to_constant(*names)
	context=assert_scope_path(*names[0..-2]) #splat 
	constant_name=names[-1..-1]
	names=context+constant_name
	path=names.join('::')
	message="names=#{names.inspect}, path=#{path.inspect}"
	begin
		object=eval(path)
	rescue
		fail message
	end #begin
	assert_not_nil(object)
end #assert_path_to_constant
def assert_constant_path_respond_to(*names)
	if names.size<2 then 
		raise "In assert_path_to_method: Not enough arguments. names=#{names.inspect}"
	elsif names.size==2 then #local object
		if self.instance_variables.include?(names[0]) then
			explain_assert_respond_to(eval(names[0]), names[1])
		else
		end #if
	else
		context=assert_scope_path(*names[0..-2])
		path=eval(context.join('::'))
		method_name=names[-1]
		message="names=#{names.inspect}, path=#{path.inspect}"
		explain_assert_respond_to(path, method_name, message)
	end #
end #assert_constant_path_respond_to
def assert_constant_instance_respond_to(*names)
	if names.size<2 then 
		raise "In assert_path_to_method: Not enough arguments. names=#{names.inspect}"
	elsif names.size==2 then #local object
		if self.instance_variables.include?(names[0]) then
			assert_public_instance_method(eval(names[0]), names[1])
		else
		end #if
	else
		context=assert_scope_path(*names[0..-2])
		path=eval(context.join('::'))
		method_name=names[-1]
		message="names=#{names.inspect}, path=#{path.inspect}"
		assert_public_instance_method(path, method_name, message)
	end #
end #assert_constant_instance_respond_to
def assert_pathname_exists(pathname, message='')
	assert_not_nil(pathname, message)
	assert_not_empty(pathname, message+"Assume pathname to not be empty.")
	assert(File.exists?(pathname), message+"File.exists?(#{pathname})=#{File.exists?(pathname).inspect}")
	assert(File.exists?(File.expand_path(pathname)), message+"File.exists?(File.expand_path(pathname))=#{File.exists?(File.expand_path(pathname)).inspect}")
end #assert_pathname_exists
def assert_data_file(pathname, message='')
	assert_pathname_exists(pathname, message)
	assert(File.file?(pathname), "File.file?(#{pathname})=#{File.file?(pathname).inspect}, is it aa directory?")
	assert_not_nil(File.size?(pathname), message)
	assert_not_equal(0, File.size?(pathname), message)
end #assert_data_file
end #Assertions
end #Unit
end #Test
#include Test::Unit::Assertions
#Test::Unit::Assertions.assert_pre_conditions

###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################

def testCallResult(obj,methodName,*arguments)
	assert_instance_of(Symbol,methodName,"testCallResult caller=#{caller.inspect}")
	explain_assert_respond_to(obj,methodName)
	m=obj.method(methodName)
	return m.call(*arguments)
end #def
def testCall(obj,methodName,*arguments)
	result=testCallResult(obj,methodName,*arguments)
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
end #def
def testAnswer(obj,methodName,answer,*arguments)
	result=testCallResult(obj,methodName,*arguments)	
	assert_equal(answer,result)
	return result
end #def

def explain_assert_respond_to(obj,methodName,message='')
	assert_not_nil(obj,"explain_assert_respond_to can\'t do much with a nil object.")
	assert_respond_to(methodName,:to_s,"methodName must be of a type that supports a to_s method.")
	assert(methodName.to_s.length>0,"methodName=\"#{methodName}\" must not be a empty string")
	message1=message+"Object #{obj.canonicalName(false)} of class='#{obj.class}' does not respond to method :#{methodName}"
	if obj.instance_of?(Class) then
		if obj.instance_methods(true).include?(methodName.to_s) then
			message= "It's an instance, not a class method."
		else
			if obj.instance_methods(false).empty? then
				message="#{message1}; has no noninherited class methods."
			else
				message="#{message1}; noninherited class methods= #{obj.instance_methods(false).inspect}"
			end #if
		end #if
		assert_respond_to(obj,methodName,message)
	else # not class
		noninherited=obj.class.public_instance_methods-obj.class.superclass.public_instance_methods
#		assert_equal(obj.class.public_instance_methods,obj.public_class_methods)
		if obj.respond_to?(methodName.to_s) then
			return # OK not ActiveRecord
		#~ elsif obj.activeRecordTableNotCreatedYet?(obj) then
			#~ message="#{message1}; noninherited instance methods= #{obj.noninherited_public_instance_methods(obj).inspect}"
		else
			message="#{message1}; noninherited instance methods= #{obj.noninherited_public_instance_methods.inspect}"
			assert_respond_to(obj,methodName,message)
		end
	end
end
def assert_not_empty(object,message=nil)
	message=build_message(message, "? is empty with value ?.", object.canonicalName,object.inspect)   
	assert_not_nil(object,message)
	assert_block(message){!object.empty?}
end #def
def assert_empty(object,message=nil)
	message=build_message(message, "? is not empty but contains ?.", object.canonicalName,object.inspect)   
	assert_block(message){object.empty? || object==Set[nil]}
end #def
def assert_flat_set(set)
	set.to_a.each do |e|
		assert(!e.instance_of?(Set))
	end
end #def
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
end #def
def assert_overlap(enum1,enum2)
	assert_not_empty(enum1)
	assert_not_empty(enum2)
	assert_block("enum1=#{enum1.inspect} does not overlap enum2=#{enum2.inspect}"){!(enum1&enum2).empty?}
end #assert_overlap
def assert_include(element,list,message=nil)
#	if message.nil? then
		message=build_message(message, "? is not in list ?", element,list.inspect)
#	end #if 
	raise "Second argument of assert_include must be an Array" if !(list.instance_of?(Array) || list.instance_of?(Set))
	assert(list.include?(element),message)
end #def
def assert_dir_include(filename,glob)
	assert_include(filename,Dir[glob],"Dir['#{glob}']=#{Dir[glob]} does not include #{filename}.")
end #def
def assert_not_include(element,list,message=nil)
	message=build_message(message, "? is in list ?", element,list)   
	assert_block(message){!list.include?(element)}
end #def
def assert_public_instance_method(obj,methodName,message='')
	#noninherited=obj.class.public_instance_methods-obj.class.superclass.public_instance_methods
	if obj.respond_to?(methodName) then
		message+='expect to pass'
	elsif obj.respond_to?(methodName.to_s.singularize) then
		message+="but singular #{methodName.to_s.singularize} is a method"
	elsif obj.respond_to?(methodName.to_s.pluralize) then
		message+="but plural #{methodName.to_s.pluralize} is a method"
	elsif obj.respond_to?(methodName.to_s.tableize) then
		message+="but tableize #{methodName.to_s.tableize} is a method"
	elsif obj.respond_to?(methodName.to_s.tableize.singularize) then
		message+="but singular tableize #{methodName.to_s.tableize.singularize} is a method"
	else
		message+="but neither singular #{methodName.to_s.singularize} nor plural #{methodName.to_s.pluralize} nor tableize #{methodName.to_s.tableize} nor singular tableize #{methodName.to_s.tableize.singularize} is a method"
	end #if
	assert_respond_to( obj, methodName,message)
end #def
def assert_array_of(obj, type)
	assert_block("obj=#{obj.inspect} must be an Array") {obj.instance_of?(Array)}
	puts "obj=#{obj.inspect} must be an Array of Strings(pathnames)"
	puts "obj.size=#{obj.size} "
	puts "obj[0]=#{obj[0].inspect} "
	obj.each do |p|
		puts "p=#{p.inspect} must be a String(pathnames)" 
	end #each
	assert_block("obj=#{obj.inspect} must be an Array of Strings(pathnames)") {obj.all?{|s| s.instance_of?(String)}}
end #array_of
def assert_attribute_of(obj, symbol, type)
	assert_block("obj[:#{symbol}]=#{obj[symbol].inspect} must be of type #{type}, but is of type #{obj[symbol].class} obj=#{obj.inspect}") {obj[symbol].instance_of?(type)}
end #array_of

def assert_has_instance_methods(model_class,message=nil)
	message=build_message(message, "? has no public instance methods.", model_class.canonicalName)   
	assert_block(message){!model_class.instance_methods(false).empty?}
end #def

def assert_model_class(model_name)
	a_fixture_record=fixtures(model_name.tableize).values.first
	assert_kind_of(ActiveRecord::Base,a_fixture_record)
	theClass=a_fixture_record.class
	assert_equal(theClass,Generic_Table.eval_constant(model_name))
end #def


###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment' # avoid recursive requires
require_relative '../../test/unit/default_test_case.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/naming_convention.rb'
class EmptyTest
end #EmptyTest
class EmptyDefaultTest < DefaultTestCase1
end #EmptyDefaultTest
class EmptyIncludedTest
include DefaultTests1
end #EmptyIncludedTest
require_relative '../../app/models/unbounded_fixnum.rb'
class NamingConventionTest <  DefaultTestCase2
#include DefaultTests2 
#include DefaultTests0    #less error messages
include NamingConvention::Constants
include NamingConvention::Examples
include NamingConvention::Assertions
#include NamingConvention::Assertions::KernelMethods
extend NamingConvention::Assertions::ClassMethods
def test_all
	All.each do |s|
		assert(!s.pattern.keys.empty?, "all=#{NamingConvention.all.inspect}")
	end #each
	assert_not_empty(All)
	assert_not_empty(NamingConvention.all)
	NamingConvention.all.each do |s|
		assert(!s.pattern.keys.empty?, "all=#{NamingConvention.all.inspect}")
		s.assert_pre_conditions
	end #each
end #all
def test_path2model_name
	path=File.expand_path($0)
	extension=File.extname(path)
	assert_equal('.rb', extension)
	basename=File.basename(path)
	assert_equal('naming_convention_test.rb', basename)
	expected_match=2
	assert_include(NamingConvention.included_modules, NamingConvention::Assertions)
	assert_include(NamingConvention.methods, :assert_pre_conditions)
	assert_respond_to(NamingConvention, :assert_pre_conditions)
	NamingConvention.assert_pre_conditions
	NamingConvention.assert_naming_convention_match(NamingConvention.all[expected_match], path)
	name_length=basename.size+extension.size-NamingConvention.all[expected_match][:suffix].size
	assert_equal(20, name_length)
	matches=NamingConvention.all.reverse.map do |s| #reversed from rare to common
		if NamingConvention.suffix_match(s, path) && NamingConvention.sub_directory_match(s, path) then
			name_length=basename.size-s[:suffix].size
			basename[0,name_length].classify.to_sym
		else
			nil
		end #if	
	end #map
	assert_not_empty(matches)
	assert_not_empty(matches.compact)
	assert_equal(:NamingConvention, matches.compact.last)
	
	path=File.expand_path(DCT_filename)
	extension=File.extname(path)
	basename=File.basename(path, extension)
	assert_equal('dct', basename)
	assert_equal('.rb', extension)
	expected_match=1
	NamingConvention.assert_naming_convention_match(NamingConvention.all[expected_match], path)
	name_length=basename.size+extension.size-NamingConvention.all[expected_match][:suffix].size
	assert_equal(3, name_length)

	model_class_name=NamingConvention.path2model_name?
	assert_equal(:NamingConvention, model_class_name)
end #path2model_name
def test_project_root_dir
	path=File.expand_path($0)
	assert_not_nil(path)
	assert_not_empty(path)
	assert(File.exists?(path))
end #project_root_dir
def test_find_by_name
	NamingConvention.all.each do |s|
		s==find_by_name(s[:name])
	end #find
end #find_by_name
def test_pathnames
	assert_instance_of(Array, UnboundedFixnumNamingConvention.pathnames?)
	assert_equal(5, UnboundedFixnumNamingConvention.pathnames?.size)
	assert_array_of(UnboundedFixnumNamingConvention.pathnames?, String)
	pathnames=Patterns.map do |p|
		UnboundedFixnumNamingConvention.pathname_pattern?(p[:name])
	end #
	assert_equal(UnboundedFixnumNamingConvention.pathnames?, pathnames)
end #pathnames
def test_initialize
	file_pattern=NamingConvention.new(Patterns[0]).pattern
	assert(!file_pattern.keys.empty?, "file_pattern=#{file_pattern.inspect}")
end #initialize
def test_suffix_match
	NamingConvention.all.each do |s|
		message="s=#{s}\nsuffix=#{s[:suffix]}"
		s.assert_pre_conditions
		message+="\ns.suffix_match(path)=#{s.suffix_match(s.path?('test'))}"
		assert(s.suffix_match(s.path?('test')), message)
	end #each
end #suffix_match
def test_sub_directory_match
	s=model_basename.all[1]
	path='script/dct.rb'
	sub_directory=File.dirname(path)
	expected_sub_directory=s[:sub_directory][0..-2] # drops trailing /
	message="expected_sub_directory=#{expected_sub_directory}\nsub_directory=#{sub_directory}"
	assert_not_nil(sub_directory[-expected_sub_directory.size,expected_sub_directory.size], message)
	assert_equal(sub_directory[-expected_sub_directory.size,expected_sub_directory.size], expected_sub_directory, message)
	message="s=#{s}\nsub_directory=#{sub_directory}\nexpected_sub_directory=#{expected_sub_directory}"
	message+="\s.sub_directory_match(path)=#{s.sub_directory_match(path)}"
	assert(s.sub_directory_match(path), message)
	assert(all[0].sub_directory_match('app/models/naming_convention_test.rb'), "NamingConvention.all[0], 'app/models/'")
	assert(NamingConvention.sub_directory_match(NamingConvention.all[1], 'script/naming_convention_test.rb'), "NamingConvention.all[1], 'script/'")
	assert(NamingConvention.sub_directory_match(NamingConvention.all[2], 'test/unit/naming_convention_test.rb'), "NamingConvention.all[2], 'test/unit/'")
	assert(NamingConvention.sub_directory_match(NamingConvention.all[3], 'test/assertions/naming_convention_test.rb'), "(NamingConvention.all[3], 'test/assertions/'")
	assert(NamingConvention.sub_directory_match(NamingConvention.all[4], 'test/unit/naming_convention_test.rb'), "(NamingConvention.all[4], 'test/unit/'")
end #sub_directory_match
def test_default_tests_module_name
end #default_tests_module?
def test_test_case_class_name
end #test_case_class?
include NamingConvention::Assertions
extend NamingConvention::Assertions::ClassMethods
#def test_class_assert_invariant
#	NamingConvention.assert_invariant
#end # class_assert_invariant
def test_class_assert_pre_conditions
#	NamingConvention.assert_pre_conditions
end #class_assert_pre_conditions
def test_class_assert_post_conditions
#	NamingConvention.assert_post_conditions
end #class_assert_post_conditions
def test_assert_naming_convention_match
	assert(NamingConvention.assert_naming_convention_match(Patterns[0], SELF.model_pathname?), "Patterns[0], 'app/models/'")
	assert(NamingConvention.assert_naming_convention_match(Patterns[1], DCT_filename), "Patterns[1], 'script/'")
	assert(NamingConvention.assert_naming_convention_match(Patterns[2], SELF.model_test_pathname?), "Patterns[2], 'test/unit/'")
	assert(NamingConvention.assert_naming_convention_match(Patterns[3], SELF.assertions_pathname?), "(Patterns[3], 'test/assertions/'")
	assert(NamingConvention.assert_naming_convention_match(Patterns[4], SELF.assertions_test_pathname?), "(Patterns[4], 'test/unit/'")
end #naming_convention_match
end #NamingConvention



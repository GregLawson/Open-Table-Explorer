###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment' # avoid recursive requires
require_relative '../../app/models/default_test_case.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/file_pattern.rb'
class FilePatternTest <  DefaultTestCase2
#include DefaultTests2 
#include DefaultTests0    #less error messages
include FilePattern::Constants
include FilePattern::Examples
include FilePattern::Assertions
#include FilePattern::Assertions::KernelMethods
extend FilePattern::Assertions::ClassMethods
def test_all
	assert_not_empty(FilePattern.all)
	assert_equal(All, FilePattern.all)
	array_message="All=#{All.inspect}"
	array_message+="\n FilePattern.all=#{FilePattern.all.inspect}"
	all=[]
	Patterns.each_with_index  do |p, i| 
		n=FilePattern.new(p)
		message=array_message+"\n recompute s=#{p.inspect}\n n=#{n.inspect}"
#		fail message
		n.assert_pre_conditions(message)
		assert_equal(n, All[i], message)
		assert_equal(n, FilePattern.all[i], message)
#		All[i].assert_pre_conditions(message)
#		FilePattern.all[i].assert_pre_conditions(message)
		all+=[n]
	end #each_with_index
	FilePattern.assert_pattern_array(all)
	FilePattern.assert_pattern_array(Patterns.map {|s| FilePattern.new(s)})
	FilePattern.assert_pattern_array(All)
#	FilePattern.assert_pattern_array(FilePattern.all)
end #all
def test_path2model_name
	path=File.expand_path($0)
	extension=File.extname(path)
	assert_equal('.rb', extension)
	basename=File.basename(path)
	assert_equal('file_pattern_test.rb', basename)
	expected_match=1
	assert_include(FilePattern.included_modules, FilePattern::Assertions)
	assert_include(FilePattern.methods, :assert_pre_conditions)
	assert_respond_to(FilePattern, :assert_pre_conditions)
	FilePattern.assert_pre_conditions
#	FilePattern.assert_naming_convention_match(Patterns[expected_match], path)
	name_length=basename.size+extension.size-Patterns[expected_match][:suffix].size
	assert_equal(15, name_length, "basename.size=#{basename.size}, extension.size=#{extension.size}\n Patterns[expected_match]=#{Patterns[expected_match].inspect}\n Patterns[expected_match][:suffix].size=#{Patterns[expected_match][:suffix].size}, ")
	matches=All.reverse.map do |s| #reversed from rare to common
		if s.suffix_match(path) && s.sub_directory_match(path) then
			name_length=basename.size-s[:suffix].size
			basename[0,name_length].classify.to_sym
		else
			nil
		end #if	
	end #map
	assert_not_empty(matches)
	assert_not_empty(matches.compact)
	assert_equal(:FilePattern, matches.compact.last)
	
	path=File.expand_path(DCT_filename)
	extension=File.extname(path)
	basename=File.basename(path, extension)
	assert_equal('dct', basename)
	assert_equal('.rb', extension)
	expected_match=2
	name_length=basename.size+extension.size-Patterns[expected_match][:suffix].size
	assert_equal(3, name_length, "basename.size=#{basename.size}, extension.size=#{extension.size}\n Patterns[expected_match]=#{Patterns[expected_match].inspect}\n Patterns[expected_match][:suffix].size=#{Patterns[expected_match][:suffix].size}, ")
	expected_match=4
	path='test/long_test/rebuild_test.rb'
	FilePattern.new(Patterns[expected_match]).assert_naming_convention_match(path)
	assert_equal(:Rebuild, FilePattern.path2model_name?(path))
end #path2model_name
def test_project_root_dir
	path=File.expand_path($0)
	assert_not_nil(path)
	assert_not_empty(path)
	assert(File.exists?(path))
end #project_root_dir
def test_find_by_name
	FilePattern::All.each do |s|
		assert_equal(s, FilePattern.find_by_name(s[:name]), s.inspect)
	end #find
end #find_by_name
def test_pathnames
	assert_instance_of(Array, FilePattern.pathnames?('test'))
	assert_equal(All.size, FilePattern.pathnames?('test').size)
	assert_array_of(FilePattern.pathnames?('test'), String)
end #pathnames
def test_initialize
	n=FilePattern.new(Patterns[0])
	n.assert_pre_conditions
	file_pattern=n
	assert(!file_pattern.keys.empty?, "file_pattern=#{file_pattern.inspect}")
	FilePattern.assert_post_conditions
end #initialize
include FilePattern::Assertions
extend FilePattern::Assertions::ClassMethods
#def test_class_assert_invariant
#	FilePattern.assert_invariant
#end # class_assert_invariant
def test_class_assert_pre_conditions
#	FilePattern.assert_pre_conditions
end #class_assert_pre_conditions
def test_class_assert_post_conditions
	FilePattern.assert_post_conditions
end #class_assert_post_conditions
def assert_pattern_srray(array)
end #assert_pattern_srray
def test_assert_naming_convention_match
	expected_match=4
	path='test/long_test/rebuild_test.rb'
	FilePattern.new(Patterns[expected_match]).assert_naming_convention_match(path)
end #naming_convention_match
end #FilePattern

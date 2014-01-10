###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment' # avoid recursive requires
require 'test/unit'
require_relative '../../app/models/default_test_case.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/file_pattern.rb'
class FilePatternTest <  DefaultTestCase2
#include DefaultTests2 
#include DefaultTests0    #less error messages
include FilePattern::Constants
include FilePattern::Examples
#include FilePattern::Assertions
#include FilePattern::Assertions::KernelMethods
extend FilePattern::Assertions::ClassMethods
def test_Constants

	assert_match(Directory_delimiter, Project_root_directory)
	assert_match(Basename_character_regexp, Project_root_directory)
	assert_match(Basename_regexp, Project_root_directory)
	assert_match(Pathname_character_regexp, Project_root_directory)
#either	assert_match(Absolute_pathname_regexp, $0)
	assert_match(Relative_directory_regexp, All[0][:sub_directory])
	assert_match(Absolute_directory_regexp, Project_root_directory)
#	assert_match(Relative_pathname_regexp, )
end #Constants
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
	assert_equal(:MatchData, FilePattern.path2model_name?('app/models/match_data.rb'))
end #path2model_name
def test_project_root_dir
	path=File.expand_path($0)
	assert_not_nil(path)
	assert_not_empty(path)
	assert(File.exists?(path))
	path="test/data_sources/tax_form/CA_540/CA_540_2012_example_out.txt"
	pattern=FilePattern.find_by_name(path)
	assert_not_nil(pattern, path)
	assert_equal(:data_soures_dir, pattern[:name])
	script_directory_pathname=File.dirname(path)+'/'
	script_directory_name=File.basename(script_directory_pathname)
	ret=case script_directory_name
	when 'unit' then
		File.expand_path(script_directory_pathname+'../../')+'/'
	when 'assertions' then
		File.expand_path(script_directory_pathname+'../../')+'/'
	when 'long_test' then
		File.expand_path(script_directory_pathname+'../../')+'/'
	when 'integration' then
		File.expand_path(script_directory_pathname+'../../')+'/'
	when 'script' then
		File.dirname(script_directory_pathname)+'/'
	when 'models'
		File.expand_path(script_directory_pathname+'../../')+'/'
	else
		fail "can't find test directory. path=#{path.inspect}\n  script_directory_pathname=#{script_directory_pathname.inspect}\n script_directory_name=#{script_directory_name.inspect}"
		script_directory_name+'/'
	end #case
	raise "ret=#{ret} does not end in a slash\npath=#{path}" if ret[-1,1]!= '/'
	assert_equal('', FilePattern.project_root_dir?(path))
end #project_root_dir
def test_find_by_name
	FilePattern::All.each do |s|
		assert_equal(s, FilePattern.find_by_name(s[:name]), s.inspect)
	end #find
end #find_by_name
def test_find_from_path
	assert_equal(:model, FilePattern.find_from_path(SELF_Model)[:name], "Patterns[0], 'app/models/'")
	assert_equal(:test, FilePattern.find_from_path(SELF_Test)[:name], "Patterns[2], 'test/unit/'")
	assert_equal(:script, FilePattern.find_from_path(DCT_filename)[:name], "Patterns[1], 'script/'")
	assert_equal(:assertions, FilePattern.find_from_path('test/assertions/_assertions.rb')[:name], "(Patterns[3], 'test/assertions/'")
	path='test/unit/_assertions_test.rb'
	p=All[4]
	assert(p.suffix_match(path))
	assert(p.sub_directory_match(path))
	assert_equal(:assertions_test, FilePattern.find_from_path(path)[:name], "(Patterns[4], 'test/unit/'")
	path="test/data_sources/tax_form/CA_540/CA_540_2012_example_out.txt"
	pattern=FilePattern.find_from_path(path)
	assert_not_nil(pattern, path)
	assert_equal(:data_sources_dir, pattern[:name])
end #find_from_path
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
def test_sub_directory_match
	path='test/unit/_assertions_test.rb'
	p=FilePattern.find_from_path(path)
	assert(p.suffix_match(path))
	assert(p.sub_directory_match(path))
	successes=All.map do |p|
		sub_directory=File.dirname(path)
		expected_sub_directory=p[:sub_directory][0..-2] # drops trailing /
		assert_equal(sub_directory[-expected_sub_directory.size,expected_sub_directory.size], expected_sub_directory)
		assert(p.sub_directory_match(p[:example_file]), p.inspect)
	end #map
end #sub_directory_match
def test_path
end #path
def test_parse_pathname_regexp
end #parse_pathname_regexp
def test_pathname_glob
end #pathname_glob
def test_relative_path
end #relative_path
def test_class_assert_pre_conditions
#	FilePattern.assert_pre_conditions
end #class_assert_pre_conditions
def test_class_assert_post_conditions
	FilePattern.assert_post_conditions
end #class_assert_post_conditions
def assert_pattern_array(array)
end #assert_pattern_array
def test_assert_naming_convention_match
	expected_match=4
	path='test/long_test/rebuild_test.rb'
	FilePattern.new(Patterns[expected_match]).assert_naming_convention_match(path)
#	te=RelatedFile.new
	assert(FilePattern.find_by_name(:model).assert_naming_convention_match(SELF_Model), "Patterns[0], 'app/models/'")
	assert(FilePattern.find_by_name(:test).assert_naming_convention_match(SELF_Test), "Patterns[2], 'test/unit/'")
	assert(FilePattern.find_by_name(:script).assert_naming_convention_match(DCT_filename), "Patterns[1], 'script/'")
	assert(FilePattern.find_by_name(:assertions).assert_naming_convention_match('test/assertions/_assertions.rb'), "(Patterns[3], 'test/assertions/'")
	assert(FilePattern.find_by_name(:assertions_test).assert_naming_convention_match('test/unit/_assertions_test.rb'), "(Patterns[4], 'test/unit/'")
end #naming_convention_match
def test_Examples
end #Examples
end #FilePattern

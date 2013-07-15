###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class NamingConvention
module Constants
	# ordered from common to rare, ambiguous to specific
	Patterns=[
	{:suffix =>'.rb', :name => :model, :sub_directory => 'app/models/'}, 
	{:suffix =>'.rb', :name => :script, :sub_directory => 'script/'}, 
	{:suffix =>'_test.rb', :name => :test, :sub_directory => 'test/unit/'}, 
	{:suffix =>'_assertions.rb', :name => :assertions, :sub_directory => 'test/assertions/'}, 
	{:suffix =>'_assertions_test.rb', :name => :assertions_test, :sub_directory => 'test/unit/'}
	]
end  #Constants
include Constants
module ClassMethods
def suffix_match(s, path)
	path[-s[:suffix].size, s[:suffix].size] == s[:suffix]
end #suffix_match
def sub_directory_match(s, path)
	path=File.expand_path(path)
	sub_directory=File.dirname(path)
	expected_sub_directory=s[:sub_directory][0..-2] # drops trailing /
	sub_directory[-expected_sub_directory.size,expected_sub_directory.size]==expected_sub_directory
end #sub_directory_match
def path2model_name?(path=$0)
	raise "path=#{path.inspect} must be a string" if !path.instance_of?(String)
	path=File.expand_path(path)
	extension=File.extname(path)
	basename=File.basename(path)
	matches=Constants::Patterns.reverse.map do |s| #reversed from rare to common
		if suffix_match(s, path) && sub_directory_match(s, path) then
			name_length=basename.size-s[:suffix].size
			basename[0,name_length].classify.to_sym
		else
			nil
		end #if	
	end #map
	matches.compact.last
end #path2model_name
def project_root_dir?(path=$0)
	path=File.expand_path(path)
	script_directory_pathname=File.dirname(path)+'/'
	script_directory_name=File.basename(script_directory_pathname)
	ret=case script_directory_name
	when 'unit' then
		File.expand_path(script_directory_pathname+'../../')+'/'
	when 'script' then
		File.dirname(script_directory_pathname)+'/'
	when 'models'
		File.expand_path(script_directory_pathname+'../../')+'/'
	else
		fail "can't find test directory"
	end #case
	raise "ret=#{ret} does not end in a slash\npath=#{path}" if ret[-1,1]!= '/'
	return ret
end #project_root_dir
def lookup(name, param_name)
	ret=Constants::Patterns.find do |s|
		s[:name]==name
	end #find
	ret[param_name]
end #lookup
#NamingConvention.assert_pre_conditions
#assert_include(NamingConvention.included_modules, :Assertions)
#assert_pre_conditions
end #ClassMethods
extend ClassMethods
attr_reader :model_basename,  :model_class_name, :project_root_dir, :edit_files, :missing_files
def initialize(model_class_name=NamingConvention.path2model_name?, project_root_dir=NamingConvention.project_root_dir?)
	message="model_class is nil\n$0=#{$0}\n model_class_name=#{model_class_name}\nFile.expand_path=File.expand_path(#{File.expand_path($0)}"
	raise message if model_class_name.nil?
	@model_class_name=model_class_name.to_sym
	if project_root_dir.nil? then
		@project_root_dir='' #empty string not nil
	else
		@project_root_dir= project_root_dir  #not nil
	end #
	@model_basename=@model_class_name.to_s.tableize.singularize
	raise "@model_basename" if @model_basename.nil?
	@edit_files, @missing_files=pathnames?.partition do |p|
		File.exists?(p)
	end #partition
end #initialize
# Equality of defining content
def ==(other)
	if model_class_name==other.model_class_name && project_root_dir==other.project_root_dir then
		true
	else
		false
	end #if
end #==
def pathname_pattern?(file_spec)
	raise "project_root_dir" if @project_root_dir.nil?
	raise "NamingConvention.lookup(file_spec, :sub_directory)" if NamingConvention.lookup(file_spec, :sub_directory).nil?
	raise "@model_basename" if @model_basename.nil?
	raise "NamingConvention.lookup(file_spec, :suffix)" if NamingConvention.lookup(file_spec, :suffix).nil?
	@project_root_dir+NamingConvention.lookup(file_spec, :sub_directory)+@model_basename.to_s+NamingConvention.lookup(file_spec, :suffix)
end #pathname_pattern
def model_pathname?
	pathname_pattern?(:model)
end #model_pathname?
def model_test_pathname?
	pathname_pattern?(:test)
end #model_test_pathname?
def assertions_pathname?
	pathname_pattern?(:assertions)
end #assertions_pathname?
def assertions_test_pathname?
	pathname_pattern?(:assertions_test)
end #assertions_test_pathname?
def data_sources_directory?
	@project_root_dir+'test/data_sources/'
end #data_sources_directory
#  Initially the number of files for the model
def default_test_class_id?
	if File.exists?(self.assertions_test_pathname?) then
		4
	elsif File.exists?(self.assertions_pathname?) then
		3
	elsif File.exists?(self.model_pathname?) then
		2
	elsif File.exists?(self.model_test_pathname?) then
		1
	else
		0 # fewest assumptions, no files
	end #if
end #default_test_class_id
def default_tests_module_name?
	"DefaultTests"+default_test_class_id?.to_s
end #default_tests_module?
def test_case_class_name?
	"DefaultTestCase"+default_test_class_id?.to_s
end #test_case_class?
def pathnames?
#	[assertions_test_pathname?, assertions_pathname?, model_test_pathname?, model_pathname?]
	raise "project_root_dir" if @project_root_dir.nil?
	raise "@model_basename" if @model_basename.nil?
	pathnames=Patterns.map do |p|
		pathname_pattern?(p[:name])
	end #
end #pathnames
def model_class?
	eval(@model_class_name.to_s)
end #model_class
def model_name?
	@model_class_name
end #model_name?
module Examples
UnboundedFixnumNamingConvention=NamingConvention.new(:UnboundedFixnum)
SELF=NamingConvention.new
DCT_filename='script/dct.rb'
#DCT=NamingConvention.new(NamingConvention.path2model_name?(DCT_filename), NamingConvention.project_root_dir?(DCT_filename))
end #Examples
module Assertions
module ClassMethods
include Test::Unit::Assertions
# conditions that are always true (at least atomically)
def assert_invariant
#	fail "end of assert_invariant "
end # class_assert_invariant
# conditions true while class is being defined
def assert_pre_conditions
	assert_respond_to(NamingConvention, :project_root_dir?)
	assert_module_included(self, NamingConvention::Assertions)
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions
	assert_equal(TE, NamingConvention::Examples::SELF)
end #class_assert_post_conditions
def assert_naming_convention_match(s, path)
	assert_equal(path[-s[:suffix].size, s[:suffix].size], s[:suffix], caller_lines)
=begin
	extension=File.extname(path)
	assert_equal('.rb', extension, caller_lines)
	basename=File.basename(path, extension)
	expected_extension=File.extname(s[:suffix])
	message="s=#{s.inspect}, extension=#{extension.inspect}"
	assert_equal(expected_extension, extension, message+caller_lines)
	if 	extension==s[:suffix] then
		extension=s[:suffix]
		expected_suffix=''
		suffix=''
	else
		expected_suffix=File.basename(s[:suffix], extension)
		suffix=path[-expected_suffix.size,expected_suffix.size]
	end #if
#	expected_suffix=File.basename(s[:suffix], extension)
	assert_equal(extension, File.extname(path), caller_lines)
	assert_equal(extension, File.basename(extension, extension), caller_lines)
#	assert_equal(suffix[-expected_suffix.size,expected_suffix.size], expected_suffix)
	message="s=#{s}\nsuffix=#{suffix}\nextension=#{extension}"
	message+="\nNamingConvention.suffix_match(s, suffix, extension)=#{NamingConvention.suffix_match(s, suffix, extension)}"
	assert_equal(suffix, expected_suffix, caller_lines)
	assert(NamingConvention.suffix_match(s, suffix, extension), message+caller_lines)
	assert(extension_match(s, extension), message+caller_lines)
	assert(suffix_match(s, suffix, extension), message+caller_lines)
=end
	sub_directory=File.dirname(path)
	expected_sub_directory=s[:sub_directory][0..-2] # drops trailing /
	message="expected_sub_directory=#{expected_sub_directory}\nsub_directory=#{sub_directory}"
	assert_not_nil(sub_directory[-expected_sub_directory.size,expected_sub_directory.size], message+caller_lines)
	assert_equal(sub_directory[-expected_sub_directory.size,expected_sub_directory.size], expected_sub_directory, message+caller_lines)
	message="s=#{s}\nsub_directory=#{sub_directory}\nexpected_sub_directory=#{expected_sub_directory}"
	message+="\nNamingConvention.sub_directory_match(s, path)=#{NamingConvention.sub_directory_match(s, path)}"
	assert(NamingConvention.sub_directory_match(s, path), message+caller_lines)

	message="s=#{s.inspect}, path=#{path.inspect}"
end #naming_convention_match
end #ClassMethods
module KernelMethods
def assert_default_test_class_id(expected_id, class_name, message='')
	te=NamingConvention.new(class_name)
	message+="te=#{te.inspect}"
	assert_equal(expected_id, te.default_test_class_id?, message+caller_lines)
end #default_test_class_id
end #KernelMethods
# conditions that are always true (at least atomically)
def assert_invariant
	fail "end of assert_invariant "
end #assert_invariant
# conditions true while class is being defined
# assertions true after class (and nested module Examples) is defined
def assert_pre_conditions
	assert_not_empty(@test_class_name, "test_class_name")
	assert_not_empty(@model_basename, "model_basename")
	fail "end ofassert_pre_conditions "
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions
	message+="\ndefault NamingConvention.project_root_dir?=#{NamingConvention.project_root_dir?.inspect}"
	assert_not_empty(@project_root_dir, message)
end #assert_post_conditions


end #Assertions
include Assertions
extend Assertions::ClassMethods
end #NamingConvention

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
	Suffixes=[
	{:suffix =>'.rb', :name => :model, :sub_directory => 'app/models/'}, 
	{:suffix =>'.rb', :name => :script, :sub_directory => 'script/'}, 
	{:suffix =>'_test.rb', :name => :test, :sub_directory => 'test/unit/'}, 
	{:suffix =>'_assertions.rb', :name => :assertions, :sub_directory => 'test/assertions/'}, 
	{:suffix =>'_assertions_test.rb', :name => :assertions_test, :sub_directory => 'test/unit/'}
	]
end  #Constants
include Constants
module ClassMethods
def naming_convention_extension(s, extension)
	extension==File.extname(s[:suffix])
end #naming_convention_match
def naming_convention_basename(s, basename, extension)
	expected_baseline=File.basename(s[:suffix], extension)
	basename[-expected_baseline.size,expected_baseline.size]==expected_baseline
end #naming_convention_match
def path2model_name?(path=$0)
	path=File.expand_path(path)
	extension=File.extname(path)
	basename=File.basename(path, extension)
	matches=Constants::Suffixes.reverse.map do |s| #reversed from rare to common
		if naming_convention_extension(s, extension) && naming_convention_basename(s, basename, extension) then
			name_length=basename.size+extension.size-s[:suffix].size
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
	case script_directory_name
	when 'unit' then
		File.expand_path(script_directory_pathname+'../../')+'/'
	when 'script' then
		File.dirname(script_directory_pathname)
	when 'models'
		File.expand_path(script_directory_pathname+'../../')+'/'
	else
		fail "can't find test directory"
	end #case
end #project_root_dir
def lookup(name, param_name)
	ret=Constants::Suffixes.find do |s|
		s[:name]==name
	end #find
	ret[param_name]
end #lookup
module Assertions
def assert_naming_convention_match(s, basename, extension)
	assert_equal(extension, File.extname(s[:suffix]))
	assert(naming_convention_extension(s, extension))
	assert(naming_convention_basename(s, basename, extension))
end #naming_convention_match
def assert_pre_conditions
	assert_module_included(self, TestIntrospection::Assertions)
end #assert_pre_conditions
end #Assertions
include Assertions
#TestIntrospection.assert_pre_conditions
#assert_include(TestIntrospection.included_modules, :Assertions)
#assert_pre_conditions
end #ClassMethods
extend ClassMethods
attr_reader :model_basename,  :model_class_name, :project_root_dir, :edit_files, :missing_files
def initialize(model_class_name=NamingConvention.path2model_name?, project_root_dir=NamingConvention.project_root_dir?)
	message="model_class is nil\n$0=#{$0}\n model_class_name=#{model_class_name}\nFile.expand_path=File.expand_path(#{File.expand_path($0)}"
	raise message if model_class_name.nil?
	@model_class_name=model_class_name.to_sym
	@project_root_dir=project_root_dir
	@model_basename=@model_class_name.to_s.tableize.singularize
	@edit_files, @missing_files=pathnames?.partition do |p|
		File.exists?(p)
	end #partition
end #initialize
# Equality of content
def ==(other)
	if model_class_name==other.model_class_name && project_root_dir==other.project_root_dir then
		true
	else
		false
	end #if
end #==
#def inspect
#	existing, missing = pathnames?.partition do |p|
#		File.exists?(p)
#	end #partition
#	ret=" test for model class "+@model_class_name.to_s+" assertions_test_pathname="
#	ret+=assertions_test_pathname?.inspect
#	ret+="\nexisting files=#{existing.inspect} \nand missing files=#{missing.inspect}"
#end #inspect
def pathname_pattern?(file_spec)
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
	[assertions_test_pathname?, assertions_pathname?, model_test_pathname?, model_pathname?]
end #pathnames
def absolute_pathnames?
	pathnames?.map {|p| File.expand_path(p)}
end #absolute_pathnames
def pathname_existance?
	absolute_pathnames?.map {|p| File.exists?(p) ? 1 : 0}
end #pathname_existance
def model_class?
	eval(@model_class_name)
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
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions
	assert_equal(TE, TestIntrospection::NamingConvention::Examples::SELF)
end #class_assert_post_conditions
end #ClassMethods
module KernelMethods
def assert_default_test_class_id(expected_id, class_name, message='')
	te=TestIntrospection::NamingConvention.new(class_name)
	message+="te=#{te.inspect}"
	assert_equal(expected_id, te.default_test_class_id?, message)
end #default_test_class_id
end #KernelMethods
include Test::Unit::Assertions
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
end #assert_post_conditions


end #Assertions
include Assertions
extend Assertions::ClassMethods
end #NamingConvention

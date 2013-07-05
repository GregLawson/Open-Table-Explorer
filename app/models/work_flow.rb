require 'test/unit'
require_relative '../../test/unit/default_test_case.rb'
require_relative '../../app/models/test_environment.rb'
require_relative '../../app/models/shell_command.rb'
class WorkFlow
attr_reader :test_environment, :edit_files
module ClassMethods
def revison_tag(branch)
		return '-r '+branch.to_s
end #revison_tag
def file_versions(filename)
	" -t #{WorkFlow.revison_tag(:master)} #{filename} #{WorkFlow.revison_tag(:compiles)} #{filename} #{WorkFlow.revison_tag(:development)} #{filename}"
end #file_versions
end #ClassMethods
extend ClassMethods
def initialize(*argv)
	raise "Arguments (argv) for WorkFlow.initialize cannot be empty" if argv.empty? 
	@test_environment=TestEnvironment.new(model_class_name=TestEnvironment.path2model_name?(argv[0]), project_root_dir=TestEnvironment.project_root_dir?(argv[0]))
	message= "edit_files do not exist\n argv=#{argv.inspect}" 
	message+= "\n @test_environment.edit_files=#{@test_environment.edit_files.inspect}" 
	message+= "\n @test_environment.missing_files=#{@test_environment.missing_files.inspect}" 
	raise message if  @test_environment.edit_files.empty?
end #initialize
def execute
	test=ShellCommands.new("ruby "+ self.test_environment.model_test_pathname?, :delay_execution)
	edit=ShellCommands.new("diffuse"+ version_comparison + test_files, :delay_execution)
	puts edit.command_string
	edit.execute.assert_post_conditions
	test.execute
	if test.success? then
		Master_Checkout.execute.assert_post_conditions
		Git_Cola.execute.assert_post_conditions
	else
		Git_Cola.execute.assert_post_conditions
	end #if
end #execute
def test_files(files=nil)
	if files.nil? then
		files=@test_environment.edit_files
	end #if
	files.join(' ')
end #test_files
def version_comparison(files=nil)
	if files.nil? then
		files=@test_environment.edit_files
	end #if
	ret=files.map do |f|
		WorkFlow.file_versions(f)
	end #map
	ret.join(' ')
end #version_comparison
require_relative '../../test/assertions/default_assertions.rb'
include DefaultAssertions
extend DefaultAssertions::ClassMethods
module Assertions
module ClassMethods
def assert_post_conditions
	assert_pathname_exists(TestFile, "assert_post_conditions")
end #assert_pre_conditions
end #ClassMethods
def assert_pre_conditions
	assert_not_nil(@test_environment)
	test_environment.assert_pre_conditions
	assert_not_empty(@test_environment.edit_files, "assert_pre_conditions, @test_environmen=#{@test_environmen.inspect}, @test_environment.edit_files=#{@test_environment.edit_files.inspect}")
end #assert_pre_conditions
end #Assertions
include Assertions
module Examples
TestFile=File.expand_path($0)
TestWorkFlow=WorkFlow.new(TestFile)
end #Examples
include Examples
#TestWorkFlow.assert_pre_conditions
module Constants

Git_Cola=ShellCommands.new("git-cola ", :delay_execution)
Master_Checkout=ShellCommands.new("git checkout master", :delay_execution)
Compiles_Checkout=ShellCommands.new("git checkout compiles", :delay_execution)
Development_Checkout=ShellCommands.new("git checkout development", :delay_execution)
CompilesSupersetOfMaster=ShellCommands.new("git log compiles..master", :delay_execution)
DevelopmentSupersetofCompiles=ShellCommands.new("git log development..compiles", :delay_execution)
end #Constants
include Constants
end #WorkFlow

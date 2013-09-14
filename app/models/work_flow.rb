###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'grit'  # sudo gem install grit
require_relative '../../test/unit/default_test_case.rb'
require_relative 'related_file.rb'
require_relative '../../app/models/shell_command.rb'
require_relative 'repository.rb'
class WorkFlow
include Grit
attr_reader :related_files, :edit_files, :repository
module ClassMethods
def revison_tag(branch)
		return '-r '+branch.to_s
end #revison_tag
end #ClassMethods
extend ClassMethods
def initialize(*argv)
	argv=argv.flatten
	raise "Arguments (argv) for WorkFlow.initialize cannot be empty" if argv.empty? 
	raise "argv must be an array." if !argv.instance_of?(Array)
	raise "argv[0]=#{argv[0].inspect} must be an String." if !argv[0].instance_of?(String)
	path2model_name=FilePattern.path2model_name?(argv[0])
	@related_files=RelatedFile.new(path2model_name, FilePattern.project_root_dir?(argv[0]))
	message= "edit_files do not exist\n argv=#{argv.inspect}" 
	message+= "\n @related_files.edit_files=#{@related_files.edit_files.inspect}" 
	message+= "\n @related_files.missing_files=#{@related_files.missing_files.inspect}" 
#	raise message if  @related_files.edit_files.empty?
  @repository=Repository.new(@related_files.project_root_dir)
end #initialize
def edit
	edit=ShellCommands.new("diffuse"+ version_comparison + test_files, :delay_execution)
	puts edit.command_string
	edit.execute.assert_post_conditions
end #edit
def emacs
	emacs=ShellCommands.new("emacs --no-splash " + @related_files.edit_files.join(' '), :delay_execution)
	puts emacs.command_string
	emacs.execute.assert_post_conditions
end #emacs
def goldilocks(filename)
	current_index=WorkFlow::Branch_enhancement.index(@repository.current_branch_name?.to_sym)
	last_slot_index=WorkFlow::Branch_enhancement.size-1
	right_index=[current_index+1, last_slot_index].min
	left_index=right_index-1 
	relative_filename=	Pathname.new(filename).relative_path_from(Pathname.new(Dir.pwd)).to_s

	" -t #{WorkFlow.revison_tag(WorkFlow::Branch_enhancement[left_index])} #{relative_filename} #{relative_filename} #{WorkFlow.revison_tag(WorkFlow::Branch_enhancement[right_index])} #{relative_filename}"
end #goldilocks
>>>>>>> 07e08bffe53125bba5b93dde0a2894a7f3a68128
def execute
	edit_default
	test_and_commit(related_files.model_test_pathname?)
end #execute
def test_files(edit_files=@related_files.edit_files)
	pairs=functional_parallelism(edit_files).map do |p|

		' -t '+p.map do |f|
			Pathname.new(f).relative_path_from(Pathname.new(Dir.pwd)).to_s
			
		end.join(' ') #map
	end #map
	pairs.join(' ')
end #test_files
def version_comparison(files=nil)
	if files.nil? then
		files=@related_files.edit_files
	end #if
	ret=files.map do |f|
		goldilocks(f)
	end #map
	ret.join(' ')
end #version_comparison
def functional_parallelism(edit_files=@related_files.edit_files)
	[
	[related_files.model_pathname?, related_files.model_test_pathname?],
	[related_files.assertions_pathname?, related_files.model_test_pathname?],
	[related_files.model_test_pathname?, related_files.pathname_pattern?(:integration_test)],
	[related_files.assertions_pathname?, related_files.assertions_test_pathname?]
	].select do |fp|
		fp-edit_files==[] # files must exist to be edited?
	end #map
end #functional_parallelism
def tested_files(executable)
	if executable!=related_files.model_test_pathname? then # script only
		[related_files.model_pathname?, executable]
	else case related_files.default_test_class_id? # test files
	when 0 then [related_files.model_test_pathname?]
	when 1 then [related_files.model_test_pathname?]
	when 2 then [related_files.model_pathname?, executable]
	when 3 then [related_files.model_pathname?, related_files.model_test_pathname?, related_files.assertions_pathname?]
	when 4 then [related_files.model_pathname?, related_files.model_test_pathname?, related_files.assertions_pathname?, related_files.assertions_test_pathname?]
	end #case
	end #if
end #tested_files
require_relative '../../test/assertions/default_assertions.rb'
include DefaultAssertions
extend DefaultAssertions::ClassMethods
module Assertions
module ClassMethods
def assert_post_conditions
	assert_pathname_exists(TestFile, "assert_post_conditions")
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
	assert_not_nil(@related_files)
	assert_not_empty(@related_files.edit_files, "assert_pre_conditions, @test_environmen=#{@test_environmen.inspect}, @related_files.edit_files=#{@related_files.edit_files.inspect}")
end #assert_pre_conditions
end #Assertions
include Assertions
#TestWorkFlow.assert_pre_conditions
module Constants
Git_Cola=ShellCommands.new("git-cola ", :delay_execution)
Branch_enhancement=[:master, :compiles, :development]
end #Constants
include Constants
module Examples
TestFile=File.expand_path($0)
TestWorkFlow=WorkFlow.new(TestFile)
include Constants
end #Examples
include Examples
end #WorkFlow

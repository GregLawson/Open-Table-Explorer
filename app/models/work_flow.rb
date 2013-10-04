###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'grit'  # sudo gem install grit
require_relative 'default_test_case.rb'
require_relative 'related_file.rb'
require_relative '../../app/models/shell_command.rb'
require_relative 'repository.rb'
class WorkFlow
#include Grit
module Constants
Branch_enhancement=[:passed, :testing, :edited]
end #Constants
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
def version_comparison(files=nil)
	if files.nil? then
		files=@related_files.edit_files
	end #if
	ret=files.map do |f|
		goldilocks(f)
	end #map
	ret.join(' ')
end #version_comparison
def goldilocks(filename, middle_branch=@repository.current_branch_name?.to_sym)
	current_index=WorkFlow::Branch_enhancement.index(middle_branch)
	last_slot_index=WorkFlow::Branch_enhancement.size-1
	right_index=[current_index+1, last_slot_index].min
	left_index=right_index-1 
	relative_filename=	Pathname.new(filename).relative_path_from(Pathname.new(Dir.pwd)).to_s

	" -t #{WorkFlow.revison_tag(WorkFlow::Branch_enhancement[left_index])} #{relative_filename} #{relative_filename} #{WorkFlow.revison_tag(WorkFlow::Branch_enhancement[right_index])} #{relative_filename}"
end #goldilocks
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
def test_files(edit_files=@related_files.edit_files)
	pairs=functional_parallelism(edit_files).map do |p|

		' -t '+p.map do |f|
			Pathname.new(f).relative_path_from(Pathname.new(Dir.pwd)).to_s
			
		end.join(' ') #map
	end #map
	pairs.join(' ')
end #test_files
def edit
	edit=ShellCommands.new("diffuse"+ version_comparison + test_files)
	puts edit.command_string
	edit.assert_post_conditions
end #edit
def emacs
	emacs=ShellCommands.new("emacs --no-splash " + @related_files.edit_files.join(' '), :delay_execution)
	puts emacs.command_string
	emacs.execute.assert_post_conditions
end #emacs
def execute
	edit_default
	test_and_commit(related_files.model_test_pathname?)
end #execute
def test(executable=@related_files.model_test_pathname?)
	begin
	push_branch=@repository.current_branch_name?
	@repository.git_command("stash save").assert_post_conditions
#	@repository.stage(:edited, @related_files.tested_files(executable))
	deserving_branch=@repository.deserving_branch?(executable)
	if @repository.recent_test.success? @repository.status.changed==[] then
		puts "exiting because I think I have nothing to do."
		@repository.recent_test.puts
		@repository.git_command('status').puts
		return
	end #if
	@repository.stage(deserving_branch, @related_files.tested_files(executable))
	@repository.git_command('checkout #{push_branch}')
	@repository.git_command('stash apply')
	@repository.git_command('checkout #{deserving_branch}')
	@repository.git_command('stash apply')
	IO.binwrite('.git/GIT_COLA_MSG', 'fixup! '+@related_files.model_class_name.to_s)	
	@repository.git_command('cola')
	@repository.recent_test.puts
	edit
	end until @repository.recent_test.success?
end #test
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_post_conditions
#	assert_pathname_exists(TestFile, "assert_post_conditions")
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
	assert_not_nil(@related_files)
	assert_not_empty(@related_files.edit_files, "assert_pre_conditions, @test_environmen=#{@test_environmen.inspect}, @related_files.edit_files=#{@related_files.edit_files.inspect}")
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#TestWorkFlow.assert_pre_conditions
include Constants
module Examples
TestFile=File.expand_path($0)
TestWorkFlow=WorkFlow.new(TestFile)
include Constants
end #Examples
include Examples
end #WorkFlow

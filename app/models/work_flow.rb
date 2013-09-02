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
class WorkFlow
include Grit
attr_reader :related_files, :edit_files
module ClassMethods
def current_branch_name?
	WorkFlow::Repo.head.name.to_sym
end #branch
def revison_tag(branch)
		return '-r '+branch.to_s
end #revison_tag
def goldilocks(filename)
	current_index=WorkFlow::Branch_enhancement.index(current_branch_name?.to_sym)
	last_slot_index=WorkFlow::Branch_enhancement.size-1
	right_index=[current_index+1, last_slot_index].min
	left_index=right_index-1 
	relative_filename=	Pathname.new(filename).relative_path_from(Pathname.new(Dir.pwd)).to_s

	" -t #{WorkFlow.revison_tag(WorkFlow::Branch_enhancement[left_index])} #{relative_filename} #{relative_filename} #{WorkFlow.revison_tag(WorkFlow::Branch_enhancement[right_index])} #{relative_filename}"
end #goldilocks
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
end #edit
def execute
	edit_default
	test_and_commit(related_files.model_test_pathname?)
end #execute
def deserving_branch?(executable=related_files.model_test_pathname?)
	test=ShellCommands.new("ruby "+executable, :delay_execution)
	test.execute
	if test.success? then
		:master
	elsif test.exit_status==1 then # 1 error or syntax error
		:development
	else
		:testing
	end #if
end #
def test(executable=related_files.model_test_pathname?)
	stage(deserving_branch?(executable), executable)
end #test
def upgrade(executable=related_files.model_test_pathname?)
	upgrade_commit(deserving_branch?(executable), executable)
end #upgrade
def best(executable=related_files.model_test_pathname?)
	upgrade_commit(deserving_branch?(executable), executable)
end #best
def downgrade(executable=related_files.model_test_pathname?)
	downgrade_commit(deserving_branch?(executable), executable)
end #downgrade
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
		WorkFlow.goldilocks(f)
	end #map
	ret.join(' ')
end #version_comparison
def upgrade_commit(target_branch, executable)
	target_index=WorkFlow::Branch_enhancement.index(target_branch)
	WorkFlow::Branch_enhancement.each_index do |b, i|
		commit_to_branch(b, executable) if i >= target_index
	end #each
end #upgrade_commit
def downgrade_commit(target_branch, executable)
	commit_to_branch(target_branch, executable)
end #downgrade_commit
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
def stage(target_branch, executable)
	if WorkFlow.current_branch_name? ==target_branch then
		push_branch=target_branch # no need for stash popping
	else
		push_branch=WorkFlow.current_branch_name?
		Stash_Save.execute.assert_post_conditions
		switch_branch=ShellCommands.new("git checkout "+target_branch.to_s).execute
		message="#{WorkFlow.current_branch_name?.inspect}!=#{target_branch.inspect}\n"
		message+="WorkFlow.current_branch_name? !=target_branch=#{WorkFlow.current_branch_name? !=target_branch}\n"
		tested_files(executable).each do |p|
			ShellCommands.new("git checkout stash "+p).execute.assert_post_conditions
		end #each
		switch_branch.puts.assert_post_conditions(message)
	end #if
	ShellCommands.new("git add "+tested_files(executable).join(' ')).execute.assert_post_conditions	
	Git_Cola.execute.assert_post_conditions
	push_branch
end #stage
def commit_to_branch(target_branch, executable)
	push_branch=stage(target_branch, executable)
	if push_branch!=target_branch then
		ShellCommands.new("git checkout "+push_branch.to_s).execute.assert_post_conditions
		ShellCommands.new("git checkout stash pop").execute.assert_post_conditions
	end #if
end #commit_to_branch
def test_and_commit(executable)
	test=ShellCommands.new("ruby "+executable, :delay_execution)
	test.execute
	if test.success? then
		commit_to_branch(:master, executable)
	elsif test.exit_status==1 then # 1 error or syntax error
		commit_to_branch(:development, executable)
	else
		commit_to_branch(:testing, executable)
	end #if
end #test
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
Stash_Save=ShellCommands.new("git stash save", :delay_execution)
Stash_Pop=ShellCommands.new("git stash pop", :delay_execution)
Git_Cola=ShellCommands.new("git-cola ", :delay_execution)
Git_status=ShellCommands.new("git status", :delay_execution)
Master_Checkout=ShellCommands.new("git checkout master", :delay_execution)
Compiles_Checkout=ShellCommands.new("git checkout compiles", :delay_execution)
Development_Checkout=ShellCommands.new("git checkout development", :delay_execution)
CompilesSupersetOfMaster=ShellCommands.new("git log compiles..master", :delay_execution)
DevelopmentSupersetofCompiles=ShellCommands.new("git log development..compiles", :delay_execution)
Root_directory=FilePattern.project_root_dir?
Repo= Grit::Repo.new(Root_directory)
Branch_enhancement=[:master, :testing, :development]
end #Constants
include Constants
module Examples
TestFile=File.expand_path($0)
TestWorkFlow=WorkFlow.new(TestFile)
include Constants
end #Examples
include Examples
end #WorkFlow

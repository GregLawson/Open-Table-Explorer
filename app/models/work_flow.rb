require 'test/unit'
require 'grit'
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
	left_index=[current_index-1, 0].max
	" -t #{WorkFlow.revison_tag(WorkFlow::Branch_enhancement[left_index])} #{filename} #{filename} #{WorkFlow.revison_tag(WorkFlow::Branch_enhancement[right_index])} #{filename}"
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
	raise message if  @related_files.edit_files.empty?
end #initialize
def edit_default
	edit=ShellCommands.new("diffuse"+ version_comparison + test_files, :delay_execution)
	puts edit.command_string
	edit.execute.assert_post_conditions
end #edit_default
def edit_all
end #edit_all
def execute
	edit_default
	test_and_commit(related_files.model_test_pathname?)
end #execute
def edit
	edit_default
end #edit
def upgrade
	executable=related_files.model_test_pathname? 
	test=ShellCommands.new("ruby "+executable, :delay_execution)
	test.execute
	if test.success? then
		upgrade_commit(:master, executable)
	elsif test.exit_status==1 then # 1 error or syntax error
		upgrade_commit(:development, executable)
	else
		upgrade_commit(:compiles, executable)
	end #if
end #upgrade
def downgrade
	executable=related_files.model_test_pathname? 
	test=ShellCommands.new("ruby "+executable, :delay_execution)
	test.execute
	if test.success? then
		downgrade_commit(:master, executable)
	elsif test.exit_status==1 then # 1 error or syntax error
		downgrade_commit(:development, executable)
	else
		downgrade_commit(:compiles, executable)
	end #if
end #downgrade
def test_files(files=nil)
	if files.nil? then
		files=@related_files.edit_files
	end #if
	' -t '+files.join(' ')
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
	WorkFlow::Branch_enhancement.each do |b|
		commit_to_branch(b, executable)
	end #each
end #upgrade_commit
def downgrade_commit(target_branch, executable)
	commit_to_branch(target_branch, executable)
end #downgrade_commit
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
def commit_to_branch(target_branch, executable)
	Stash_Save.execute.assert_post_conditions
	if WorkFlow.current_branch_name?!=target_branch then
		push_branch=WorkFlow.current_branch_name?
		switch_branch=ShellCommands.new("git checkout "+target_branch.to_s).execute
		message="#{WorkFlow.current_branch_name?}!=#{target_branch}"
		switch_branch.assert_post_conditions(message)
		ShellCommands.new("git checkout stash "+tested_files(executable).join(' ')).execute.assert_post_conditions
	end #if
	ShellCommands.new("git add "+tested_files(executable).join(' ')).execute.assert_post_conditions
	Git_Cola.execute.assert_post_conditions
	if push_branch!=target_branch then
		ShellCommands.new("git checkout "+push_branch.to_s).execute.assert_post_conditions
		Stash_Pop.execute.assert_post_conditions
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
		commit_to_branch(:compiles, executable)
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
Master_Checkout=ShellCommands.new("git checkout master", :delay_execution)
Compiles_Checkout=ShellCommands.new("git checkout compiles", :delay_execution)
Development_Checkout=ShellCommands.new("git checkout development", :delay_execution)
CompilesSupersetOfMaster=ShellCommands.new("git log compiles..master", :delay_execution)
DevelopmentSupersetofCompiles=ShellCommands.new("git log development..compiles", :delay_execution)
Root_directory=FilePattern.project_root_dir?
Repo= Grit::Repo.new(Root_directory)
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

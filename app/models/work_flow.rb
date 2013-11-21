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
Branch_compression={:success	=> 0,
			:single_test_fail 	=> 1,
			:multiple_tests_fail	=> 2,
			:initialization_fail => 2,
			:syntax_error        => 2
			}
end #Constants
include Constants
@@cached_unit_versions={}
module ClassMethods
def revison_tag(branch)
		return '-r '+branch.to_s
end #revison_tag
end #ClassMethods
extend ClassMethods
# Define related (unit) versions
# Use as current, lower/upper bound, branch history
# parametized by related files, repository, branch_number, executable
# record error_score, recent_test, time
attr_reader :related_files, :edit_files, :repository
def initialize(testable_file, related_files=nil)
	path2model_name=FilePattern.path2model_name?(testable_file)
	related_files=RelatedFile.new(path2model_name, FilePattern.project_root_dir?(testable_file))
#	message= "edit_files do not exist\n argv=#{argv.inspect}" 
	message+= "\n related_files.edit_files=#{related_files.edit_files.inspect}" 
	message+= "\n related_files.missing_files=#{related_files.missing_files.inspect}" 
#	raise message if  @related_files.edit_files.empty?
	repository=Repository.new(related_files.project_root_dir)
	@testable_file=testable_file
	@related_files=related_files
	@repository=repository
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
def minimal_comparison?
	FilePattern::All.map do |p|
		min_path=Pathname.new(p.pathname_glob('minimal'+@related_files.default_test_class_id?.to_s)).relative_path_from(Pathname.new(Dir.pwd)).to_s
		path=Pathname.new(p.pathname_glob(@related_files.model_basename)).relative_path_from(Pathname.new(Dir.pwd)).to_s
		puts "File.exists?('#{min_path}')==#{File.exists?(min_path)}, File.exists?('#{path}')==#{File.exists?(path)}" if $VERBOSE
		if File.exists?(min_path) && File.exists?(path) then
			' -t '+path+' '+min_path
		end #if
	end.compact.join #map
end #minimal_comparison
def deserving_branch?(executable=@related_files.model_test_pathname?)
		error_score=@repository.error_score?(executable)
		error_classification=Repository::Error_classification.fetch(error_score, :multiple_tests_fail)
		branch_compression=Branch_compression[error_classification]
		branch_enhancement=Branch_enhancement[branch_compression]
end #deserving_branch
def edit
	edit=ShellCommands.new("diffuse"+ version_comparison + test_files)
	puts edit.command_string
	edit.assert_post_conditions
end #edit
def minimal_edit
	edit=ShellCommands.new("diffuse"+ version_comparison + test_files + minimal_comparison?)
	puts edit.command_string
	edit.assert_post_conditions
end #minimal_edit
def emacs(executable=@related_files.model_test_pathname?)
	emacs=ShellCommands.new("emacs --no-splash " + @related_files.edit_files.join(' '))
	puts emacs.command_string
	emacs.assert_post_conditions
end #emacs
def test(executable=@related_files.model_test_pathname?)
	begin
		deserving_branch=deserving_branch?(executable)
		puts deserving_branch if $VERBOSE
		@repository.safely_visit_branch(deserving_branch) do |changes_branch|
			@repository.validate_commit(changes_branch, @related_files.tested_files(executable))
		end #safely_visit_branch
		@repository.recent_test.puts
		edit
	end until !@repository.something_to_commit? 
end #test
def unit_test(executable=@related_files.model_test_pathname?)
	begin
		deserving_branch=deserving_branch?(executable)
		if @repository.recent_test.success? then
			break
		end #if
		@repository.recent_test.puts
		puts deserving_branch if $VERBOSE
		@repository.safely_visit_branch(deserving_branch) do |changes_branch|
			@repository.validate_commit(changes_branch, @related_files.tested_files(executable))
		end #safely_visit_branch
		if !@repository.something_to_commit? then
			@repository.confirm_branch_switch(deserving_branch)
		end #if
		edit
	end until !@repository.something_to_commit? 
end #unit_test
def all(pattern_name=:test)
	pattern=FilePattern.find_by_name(pattern_name)
	glob=pattern.pathname_glob
	tests=Dir[glob]
	puts tests.inspect if $VERBOSE
	tests.each do |test|
		WorkFlow.new(test).unit_test
	end #each
end #test_unit_test_all
def execute(executable=@related_files.model_test_pathname?)
	begin
	push_branch=@repository.current_branch_name?
	@repository.git_command("stash save").assert_post_conditions
#	@repository.stage(:edited, @related_files.tested_files(executable))
	deserving_branch=deserving_branch?(executable)
	@repository.stage(deserving_branch, @related_files.tested_files(executable))
	@repository.git_command('checkout #{push_branch}')
	@repository.git_command('stash apply')
	@repository.git_command('checkout #{deserving_branch}')
#	@repository.git_command('stash apply')
	IO.binwrite('.git/GIT_COLA_MSG', 'fixup! '+@related_files.model_class_name.to_s)	
	@repository.git_command('cola')
	@repository.recent_test.puts
	edit
	end
end #test
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
#	assert_pathname_exists(TestFile, "assert_post_conditions")
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
	assert_not_nil(@related_files)
	assert_not_empty(@related_files.edit_files, "assert_pre_conditions, @test_environmen=#{@test_environmen.inspect}, @related_files.edit_files=#{@related_files.edit_files.inspect}")
	assert_kind_of(Grit::Repo, @repository.grit_repo)
	assert_respond_to(@repository.grit_repo, :status)
	assert_respond_to(@repository.grit_repo.status, :changed)
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
def assert_deserving_branch(branch_expected, executable, message='')
	deserving_branch=deserving_branch?(executable)
	recent_test=shell_command("ruby "+executable)
	message+="\nrecent_test="+recent_test.inspect
	message+="\nrecent_test.process_status="+recent_test.process_status.inspect
	syntax_test=shell_command("ruby -c "+executable)
	message+="\nsyntax_test="+syntax_test.inspect
	message+="\nsyntax_test.process_status="+syntax_test.process_status.inspect
	message+="\nbranch_expected=#{branch_expected.inspect}"
	message+="\ndeserving_branch=#{deserving_branch.inspect}"
	case deserving_branch
	when :edited then
		assert_equal(1, recent_test.process_status.exitstatus, message)
		assert_not_equal("Syntax OK\n", syntax_test.output, message)
		assert_equal(1, syntax_test.process_status.exitstatus, message)
	when :testing then
		assert_operator(1, :<=, recent_test.process_status.exitstatus, message)
		assert_equal("Syntax OK\n", syntax_test.output, message)
	when :passed then
		assert_equal(0, recent_test.process_status.exitstatus, message)
		assert_equal("Syntax OK\n", syntax_test.output, message)
	end #case
	assert_equal(deserving_branch, branch_expected, message)
end #deserving_branch
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

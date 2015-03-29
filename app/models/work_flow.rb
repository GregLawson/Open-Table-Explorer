###########################################################################
#    Copyright (C) 2013-14 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'unit.rb'
require_relative 'repository.rb'
class WorkFlow
module Constants
Branch_enhancement = [:passed, :testing, :edited] # higher inex means more enhancements/bugs
Extended_branches = { -2 => :'origin/master', -1 => :master }
First_slot_index = Extended_branches.keys.min
Last_slot_index = Branch_enhancement.size + 10 # how many is too slow?
Deserving_commit_to_branch = { success:             0,
				single_test_fail:    1,
			              multiple_tests_fail: 1, # visibility boundary
			              initialization_fail: 2,
			              syntax_error:        2
			}
Expected_next_commit_branch = { success:             0,
							  single_test_fail:    0,
			              multiple_tests_fail: 1, # visibility boundary
			              initialization_fail: 1,
			              syntax_error:        2
			}
end # Constants
include Constants
module ClassMethods
include Constants
def all(pattern_name = :test)
	pattern = FilePattern.find_by_name(pattern_name)
	glob = FilePattern.new(pattern).pathname_glob
	tests = Dir[glob].sort do |x, y|
		-(File.mtime(x) <=> File.mtime(y)) # reverse order; most recently changed first
	end # sort
	puts tests.inspect if $VERBOSE
	tests.each do |test|
		WorkFlow.new(test).unit_test
	end # each
end # all
def branch_symbol?(branch_index)
	case branch_index
	when nil then fail 'branch_index=' + branch_index.inspect
	when -2 then :'origin/master'
	when -1 then :master
	when 0..WorkFlow::Branch_enhancement.size - 1 then WorkFlow::Branch_enhancement[branch_index]
	when WorkFlow::Branch_enhancement.size then :stash
	else
		('stash~' + (branch_index - WorkFlow::Branch_enhancement.size).to_s).to_sym
	end # case
end # branch_symbol?
def branch_index?(branch_name)
	branch_index = Branch_enhancement.index(branch_name.to_sym)
	if branch_index.nil? then
		if branch_name.to_s[0, 5] == 'stash' then
			stash_depth = branch_name.to_s[6, branch_name.size - 1].to_i
			branch_index = stash_depth + Branch_enhancement.size
		end # if
		Extended_branches.each_pair do |index, branch|
			branch_index = index if branch == branch_name.to_sym
		end # each_pair
	end # if
	branch_index
end # branch_index?
def revison_tag?(branch_index)
	'-r ' + branch_symbol?(branch_index).to_s
end # revison_tag?
def merge_range(deserving_branch)
	deserving_index = WorkFlow.branch_index?(deserving_branch)
	if deserving_index.nil? then
		fail deserving_branch.inspect + ' not found in ' + Branch_enhancement.inspect + ' or ' + Extended_branches.inspect
	else
		deserving_index + 1..Branch_enhancement.size - 1
	end # if
end # merge_range
end # ClassMethods
extend ClassMethods
# Define related (unit) versions
# Use as current, lower/upper bound, branch history
# parametized by related files, repository, branch_number, executable
# record error_score, recent_test, time
attr_reader :related_files, :edit_files, :repository
def initialize(specific_file,
	related_files = Unit.new_from_path?(specific_file),
	repository = Repository.new(FilePattern.repository_dir?, :interactive))

	@specific_file = specific_file
	@related_files = related_files
	@repository = repository
	index = Branch_enhancement.index(repository.current_branch_name?)
	if index.nil? then
		@branch_index = First_slot_index
	else
		@branch_index = index
	end # if
end # initialize
def version_comparison(files = nil)
	if files.nil? then
		files = @related_files.edit_files
	end # if
	ret = files.map do |f|
		goldilocks(f)
	end # map
	ret.join(' ')
end # version_comparison
def diff_command?(filename, branch_index)
	fail filename + ' does not exist.' if !File.exists?(filename)
	branch_string = WorkFlow.branch_symbol?(branch_index).to_s
	git_command = "diff --summary --shortstat #{branch_string} -- " + filename
	diff_run = @repository.git_command(git_command)
end # diff_command?
def reflog?(filename)
	@repository.git_command("reflog  --all --pretty=format:%gd,%gD,%h -- " + filename)
end # reflog?
def last_change?(filename)
	reflog?(filename).output.split("/n")[0].split(',')[0]
end # last_change?
# What happens to non-existant versions? returns nil Are they different? 
# What do I want?
def working_different_from?(filename, branch_index)
	diff_run = diff_command?(filename, branch_index)
	if diff_run.output == '' then
		false # no difference
	elsif diff_run.output.split("\n").size == 2 then
		nil # missing version
	else
		true # real difference
	end # if
end # working_different_from?
def differences?(filename, range)
	differences = range.map do |branch_index|
		working_different_from?(filename, branch_index)
	end # map
end # differences?
def scan_verions?(filename, range, direction)
	differences = differences?(filename, range)
	different_indices = []
	existing_indices = []
	range.zip(differences) do |index, s|
		case s
		when true then
			different_indices << index
			existing_indices << index
		when nil then
		when false then
			existing_indices << index
		else
			fail 'else ' + local_variables.map{|v| eval(v).inspect}.join("\n")
		end # case
	end # zip
	case direction
	when :first then
		(different_indices + [existing_indices[-1]]).min
	when :last then
		([existing_indices[0]] + different_indices).max
	else
		fail
	end # case
end # scan_verions?
def bracketing_versions?(filename, current_index)
	left_index = scan_verions?(filename, First_slot_index..current_index, :last)
	right_index = scan_verions?(filename, current_index + 1..Last_slot_index, :first)
	[left_index, right_index]
end # bracketing_versions?
def goldilocks(filename, middle_branch = @repository.current_branch_name?.to_sym)
	if File.exists?(filename) then
		current_index=WorkFlow.branch_index?(middle_branch)
		left_index,right_index=bracketing_versions?(filename, current_index)
		relative_filename=Pathname.new(File.expand_path(filename)).relative_path_from(Pathname.new(Dir.pwd)).to_s

		" -t #{WorkFlow.revison_tag?(left_index)} #{relative_filename} #{relative_filename} #{WorkFlow.revison_tag?(right_index)} #{relative_filename}"
	else
		''
	end #if
end #goldilocks
def test_files(edit_files = @related_files.edit_files)
	pairs = @related_files.functional_parallelism(edit_files).map do |p|

		' -t ' + p.map do |f|
			Pathname.new(f).relative_path_from(Pathname.new(Dir.pwd)).to_s

		end.join(' ') # map
	end # map
	pairs.join(' ')
end # test_files
def minimal_comparison?
	FilePattern::All.map do |p|
		min_path=Pathname.new(p.pathname_glob('minimal'+@related_files.default_test_class_id?.to_s)).relative_path_from(Pathname.new(Dir.pwd)).to_s
		path=Pathname.new(p.pathname_glob(@related_files.model_basename)).relative_path_from(Pathname.new(Dir.pwd)).to_s
		puts "File.exists?('#{min_path}')==#{File.exists?(min_path)}, File.exists?('#{path}')==#{File.exists?(path)}" if $VERBOSE
		if File.exists?(min_path) && File.exists?(path) then
			' -t '+path+' '+min_path
		end # if
	end.compact.join # map
end # minimal_comparison
def deserving_branch?(executable = @related_files.model_test_pathname?)
	if File.exists?(executable) then
		@error_score = @repository.error_score?(executable)
		@error_classification = Repository::Error_classification.fetch(@error_score, :multiple_tests_fail)
		@deserving_commit_to_branch = Deserving_commit_to_branch[@error_classification]
		@expected_next_commit_branch = Expected_next_commit_branch[@error_classification]
		@branch_enhancement = Branch_enhancement[@deserving_commit_to_branch]
	else
		:edited
	end # if
end # deserving_branch
def merge_conflict_recovery
# see man git status
	if File.exists?('.git/MERGE_HEAD') then
		@repository.merge_conflict_files?.each do |conflict|

			case conflict[:conflict]
			# DD unmerged, both deleted
			when 'DD' then fail Exception.new(conflict.inspect)
			# AU unmerged, added by us
			when 'AU' then fail Exception.new(conflict.inspect)
			# UD unmerged, deleted by them
			when 'UD' then fail Exception.new(conflict.inspect)
			# UA unmerged, added by them
			when 'UA' then fail Exception.new(conflict.inspect)
			# DU unmerged, deleted by us
			when 'DU' then fail Exception.new(conflict.inspect)
			# AA unmerged, both added
			when 'AA' then fail Exception.new(conflict.inspect)
			# UU unmerged, both modified
			when 'UU' then
				WorkFlow.new(conflict[:file]).edit('merge_conflict_recovery')
				@repository.validate_commit(@repository.current_branch_name?, [conflict[:file]])
			else
				fail Exception.new(conflict.inspect)
			end # case
		end # each
		@repository.confirm_commit
	else
		puts 'No merge conflict'
	end # if
end # merge_conflict_recovery
def merge(target_branch, source_branch, interact=:interactive)
	puts 'merge('+target_branch.inspect+', '+source_branch.inspect+', '+interact.inspect+')'
	@repository.safely_visit_branch(target_branch) do |changes_branch|
		merge_status = @repository.git_command('merge --no-commit ' + source_branch.to_s)
		if merge_status.output == "Automatic merge went well; stopped before committing as requested\n" then
		else
			if merge_status.success? then
			else
				merge_conflict_recovery
			end # if
		end # if
		@repository.confirm_commit(interact)
	end # safely_visit_branch
end # merge
def edit(context = nil)
	if context.nil? then
	else
	end # if
	@repository.recent_test.puts if !@repository.recent_test.nil?
	if @related_files.edit_files.empty? then
		command_string = 'diffuse' + version_comparison([@specific_file]) + test_files
	else
		command_string = 'diffuse' + version_comparison + test_files
	end # if
	puts command_string if $VERBOSE
	edit = @repository.shell_command(command_string)
	edit = edit.tolerate_status_and_error_pattern(0, /Warning/)
	status =edit
#	status.assert_post_conditions
end # edit
def split(executable, new_base_name)
	related_files = work_flow.related_files
	new_unit = Unit.new(new_base_name, project_root_dir)
	related_files.edit_files. map do |f|
		pattern_name = FilePattern.find_by_file(f)
		split_tab += ' -t ' + f + new_unit.pattern?(pattern_name)
		@repository.shell_command('cp ' + f +  new_unit.pattern?(pattern_name))
	end #map
	edit = @repository.shell_command('diffuse' + version_comparison + test_files + split_tab)
	puts edit.command_string
	edit.assert_post_conditions
end # split
def minimal_edit
	edit = @repository.shell_command('diffuse' + version_comparison + test_files + minimal_comparison?)
	puts edit.command_string
	edit.assert_post_conditions
end # minimal_edit
def emacs(executable = @related_files.model_test_pathname?)
	emacs = @repository.shell_command('emacs --no-splash ' + @related_files.edit_files.join(' '))
	puts emacs.command_string
	emacs.assert_post_conditions
end # emacs
def merge_down(deserving_branch = @repository.current_branch_name?)
	WorkFlow.merge_range(deserving_branch).each do |i|
		@repository.safely_visit_branch(Branch_enhancement[i]) do |changes_branch|
			puts 'merge(' + Branch_enhancement[i].to_s + '), ' + Branch_enhancement[i - 1].to_s + ')' if !$VERBOSE.nil?
			merge(Branch_enhancement[i], Branch_enhancement[i - 1])
			merge_conflict_recovery
			@repository.confirm_commit(:interactive)
		end # safely_visit_branch
	end # each
end # merge_down
def script_deserves_commit!(deserving_branch)
	if working_different_from?($PROGRAM_NAME, 	WorkFlow.branch_index?(deserving_branch)) then
		repository.stage_files(deserving_branch, related_files.tested_files($PROGRAM_NAME))
		merge_down(deserving_branch)
	end # if
end # script_deserves_commit!
def test(executable = @related_files.model_test_pathname?)
	merge_conflict_recovery
	deserving_branch = deserving_branch?(executable)
	puts deserving_branch if $VERBOSE
	@repository.safely_visit_branch(deserving_branch) do |changes_branch|
		@repository.validate_commit(changes_branch, @related_files.tested_files(executable))
	end # safely_visit_branch
	current_branch = repository.current_branch_name?

	if WorkFlow.branch_index?(current_branch) > WorkFlow.branch_index?(deserving_branch) then
		@repository.validate_commit(current_branch, @related_files.tested_files(executable))
	end # if
	deserving_branch
end # test
def loop(executable = @related_files.model_test_pathname?)
	merge_conflict_recovery
	@repository.safely_visit_branch(:master) do |changes_branch|
		begin
			deserving_branch = deserving_branch?(executable)
			puts "deserving_branch=#{deserving_branch} != :passed=#{deserving_branch != :passed}"
			if !File.exists?(executable) then
				done = true
			elsif deserving_branch != :passed then # master corrupted
				edit('master branch not passing')
				done = false
			else
				done = true
			end # if
		end until done
		@repository.confirm_commit(:interactive)
#		@repository.validate_commit(changes_branch, @related_files.tested_files(executable))
	end # safely_visit_branch
	begin
		deserving_branch = test(executable)
		merge_down(deserving_branch)
		edit('loop')
		if @repository.something_to_commit? then
			done = false
		else
			if @expected_next_commit_branch == @repository.current_branch_name? then
				done = true # branch already checked
			else
				done = false # check other branch
				@repository.confirm_branch_switch(@expected_next_commit_branch)
				puts 'Switching to deserving branch' + @expected_next_commit_branch.to_s
			end # if
		end # if
	end until done
end # test
def unit_test(executable = @related_files.model_test_pathname?)
	begin
		deserving_branch = deserving_branch?(executable)
		if !@repository.recent_test.nil? && @repository.recent_test.success? then
			break
		end # if
		@repository.recent_test.puts
		puts deserving_branch if $VERBOSE
		@repository.safely_visit_branch(deserving_branch) do |changes_branch|
			@repository.validate_commit(changes_branch, @related_files.tested_files(executable))
		end # safely_visit_branch
#		if !@repository.something_to_commit? then
#			@repository.confirm_branch_switch(deserving_branch)
#		end #if
		edit('unit_test')
	end until !@repository.something_to_commit?
end # unit_test
require_relative '../../test/assertions.rb'
module Assertions

module ClassMethods

def assert_pre_conditions
end # assert_pre_conditions
def assert_post_conditions
#	assert_pathname_exists(TestFile, "assert_post_conditions")
end # assert_post_conditions
end # ClassMethods
def assert_pre_conditions
	assert_not_nil(@related_files)
	assert_not_empty(@related_files.edit_files, "assert_pre_conditions, @test_environmen=#{@test_environmen.inspect}, @related_files.edit_files=#{@related_files.edit_files.inspect}")
	assert_kind_of(Grit::Repo, @repository.grit_repo)
	assert_respond_to(@repository.grit_repo, :status)
	assert_respond_to(@repository.grit_repo.status, :changed)
end # assert_pre_conditions
def assert_post_conditions
	odd_files = Dir['/home/greg/Desktop/src/Open-Table-Explorer/test/unit/*_test.rb~HEAD*']
	assert_empty(odd_files, 'WorkFlow#assert_post_conditions')
end # assert_post_conditions
def assert_deserving_branch(branch_expected, executable, message = '')
	deserving_branch = deserving_branch?(executable)
	recent_test = shell_command('ruby ' + executable)
	message += "\nrecent_test=" + recent_test.inspect
	message += "\nrecent_test.process_status=" + recent_test.process_status.inspect
	syntax_test = shell_command('ruby -c ' + executable)
	message += "\nsyntax_test=" + syntax_test.inspect
	message += "\nsyntax_test.process_status=" + syntax_test.process_status.inspect
	message += "\nbranch_expected=#{branch_expected.inspect}"
	message += "\ndeserving_branch=#{deserving_branch.inspect}"
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
	end # case
	assert_equal(deserving_branch, branch_expected, message)
end # deserving_branch
end # Assertions
include Assertions
extend Assertions::ClassMethods
# TestWorkFlow.assert_pre_conditions
include Constants
module Examples
TestFile = File.expand_path($PROGRAM_NAME)
TestWorkFlow = WorkFlow.new(TestFile)
File_not_in_oldest_branch = 'test/long_test/repository_test.rb'
Most_stable_file = 'test/unit/minimal2_test.rb'
Formerly_existant_file = 'test/unit/related_file.rb'
include Constants
end # Examples
include Examples
end # WorkFlow

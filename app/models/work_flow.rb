###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'default_test_case.rb'
require_relative 'related_file.rb'
require_relative 'repository.rb'
class WorkFlow
module Constants
Branch_enhancement=[:passed, :testing, :edited]
Extended_branches={-2 => :'origin/master', -1 => :master}
First_slot_index=Extended_branches.keys.min
Last_slot_index=Branch_enhancement.size+10 # how many is too slow?
Branch_compression={:success	=> 0,
			:single_test_fail 	=> 1,
			:multiple_tests_fail	=> 1, # visibility boundary
			:initialization_fail => 2,
			:syntax_error        => 2
			}
end #Constants
include Constants
@@cached_unit_versions={}
module ClassMethods
include Constants
def all(pattern_name=:test)
	pattern=FilePattern.find_by_name(pattern_name)
	glob=pattern.pathname_glob
	tests=Dir[glob].sort do |x,y|
		-(File.mtime(x) <=> File.mtime(y)) # reverse order; most recently changed first
	end #sort
	puts tests.inspect if $VERBOSE
	tests.each do |test|
		WorkFlow.new(test).unit_test
	end #each
end #all
def branch_symbol?(branch_index)
	case branch_index
	when -2 then :'origin/master'
	when -1 then :master
	when 0..WorkFlow::Branch_enhancement.size-1 then WorkFlow::Branch_enhancement[branch_index]
	when WorkFlow::Branch_enhancement.size then :stash
	else 
		('stash~'+(branch_index-WorkFlow::Branch_enhancement.size).to_s).to_sym
	end #case
end #branch_symbol?
def branch_index?(branch_name)
	branch_index=Branch_enhancement.index(branch_name.to_sym)
	if branch_index.nil? then
		if branch_name.to_s[0, 5]== 'stash' then
			stash_depth=branch_name.to_s[6, branch_name.size-1].to_i
			branch_index=stash_depth+Branch_enhancement.size
		end #if
		Extended_branches.each_pair do |index, branch|
			branch_index=index if branch==branch_name.to_sym
		end #each_pair
	end #if
	branch_index
end #branch_index?
def revison_tag?(branch_index)
	return '-r '+branch_symbol?(branch_index).to_s
end #revison_tag?
def merge_range(deserving_branch)
	deserving_index=WorkFlow.branch_index?(deserving_branch)
	if deserving_index.nil? then
		raise deserving_branch.inspect+' not found in '+Branch_enhancement.inspect+' or '+Extended_branches.inspect
	else
		deserving_index+1..Branch_enhancement.size-1
	end #if
end #merge_range
end #ClassMethods
extend ClassMethods
# Define related (unit) versions
# Use as current, lower/upper bound, branch history
# parametized by related files, repository, branch_number, executable
# record error_score, recent_test, time
attr_reader :related_files, :edit_files, :repository
def initialize(testable_file, 
	related_files=RelatedFile.new_from_path?(testable_file),
	repository=Repository.new(related_files.project_root_dir))
#	message= "edit_files do not exist\n argv=#{argv.inspect}" 
#	message+= "\n related_files.edit_files=#{related_files.edit_files.inspect}" 
#	message+= "\n related_files.missing_files=#{related_files.missing_files.inspect}" 
#	raise message if  @related_files.edit_files.empty?
	@testable_file=testable_file
	@related_files=related_files
	@repository=repository
	index=Branch_enhancement.index(repository.current_branch_name?)
	if index.nil? then
		@branch_index=First_slot_index
	else
		@branch_index=index
	end #if
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
def working_different_from?(filename, branch_index)
	raise filename+" does not exist." if !File.exists?(filename)
	diff_run=@repository.git_command("diff --summary --shortstat #{WorkFlow.branch_symbol?(branch_index).to_s} -- "+filename)
	if diff_run.output=='' then
		false # no difference
	elsif diff_run.output.split("\n").size>=2 then
		false # missing version
	else
		true # real difference
	end #if
end #working_different_from?
def different_indices?(filename, range)
	differences=range.map do |branch_index|
		working_different_from?(filename, branch_index)
	end #map
	indices=[]
	range.zip(differences){|n,s| indices<<(s ? n : nil)}
	indices.compact
end #different_indices?
def scan_verions?(filename, range, direction)
	case direction
	when :first then (different_indices?(filename, range)+[Last_slot_index]).min
	when :last then ([First_slot_index]+different_indices?(filename, range)).max
	else
		raise 
	end #case
end #scan_verions?
def bracketing_versions?(filename, current_index)
	left_index=scan_verions?(filename, First_slot_index..current_index, :last)
	right_index=scan_verions?(filename, current_index+1..Last_slot_index, :first)
	[left_index, right_index]
end #bracketing_versions?
def goldilocks(filename, middle_branch=@repository.current_branch_name?.to_sym)
	current_index=WorkFlow.branch_index?(middle_branch)
	left_index,right_index=bracketing_versions?(filename, current_index)
	relative_filename=Pathname.new(File.expand_path(filename)).relative_path_from(Pathname.new(Dir.pwd)).to_s

	" -t #{WorkFlow.revison_tag?(left_index)} #{relative_filename} #{relative_filename} #{WorkFlow.revison_tag?(right_index)} #{relative_filename}"
end #goldilocks
def test_files(edit_files=@related_files.edit_files)
	pairs=@related_files.functional_parallelism(edit_files).map do |p|

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
def merge_conflict_recovery
# see man git status
	if File.exists?('.git/MERGE_HEAD') then
		@repository.merge_conflict_files?.each do |conflict|

			case conflict[:conflict]
			# DD unmerged, both deleted
			when 'DD' then raise conflict.inspect
			# AU unmerged, added by us
			when 'AU' then raise conflict.inspect
			# UD unmerged, deleted by them
			when 'UD' then raise conflict.inspect
			# UA unmerged, added by them
			when 'UA' then raise conflict.inspect
			# DU unmerged, deleted by us
			when 'DU' then raise conflict.inspect
			# AA unmerged, both added
			when 'AA' then raise conflict.inspect
			# UU unmerged, both modified
			when 'UU' then 
				WorkFlow.new(conflict[:file]).edit
				@repository.validate_commit(@repository.current_branch_name?, [conflict[:file]])
			else
				raise conflict.inspect
			end #case
		end #each
		@repository.confirm_commit(:interactive)
	else
		puts 'No merge conflict'
	end #if
end #merge_conflict_recovery
def merge(target_branch, source_branch, interact=:interactive)
	@repository.safely_visit_branch(target_branch) do |changes_branch|
		merge_status=@repository.git_command('merge --no-commit '+source_branch.to_s).assert_post_conditions
		merge_conflict_recovery
		@repository.confirm_commit(interact)
	end #safely_visit_branch
end #merge
def edit
	command_string="diffuse"+ version_comparison + test_files
	puts command_string if $VERBOSE
	edit=@repository.shell_command(command_string)
	edit.assert_post_conditions
end #edit
def minimal_edit
	edit=@repository.shell_command("diffuse"+ version_comparison + test_files + minimal_comparison?)
	puts edit.command_string
	edit.assert_post_conditions
end #minimal_edit
def emacs(executable=@related_files.model_test_pathname?)
	emacs=@repository.shell_command("emacs --no-splash " + @related_files.edit_files.join(' '))
	puts emacs.command_string
	emacs.assert_post_conditions
end #emacs
def merge_down(deserving_branch=@repository.current_branch_name?)
	WorkFlow.merge_range(deserving_branch).each do |i|
		@repository.safely_visit_branch(Branch_enhancement[i]) do |changes_branch|
			merge(Branch_enhancement[i], Branch_enhancement[i-1])
			merge_conflict_recovery
			@repository.confirm_commit(:interactive)
			puts 'merge('+Branch_enhancement[i].to_s+', '+Branch_enhancement[i-1].to_s+')'
		end #safely_visit_branch
	end #each
end #merge_down
def script_deserves_commit!(deserving_branch)
	if working_different_from?($0, 	WorkFlow.branch_index?(deserving_branch)) then
		repository.stage_files(deserving_branch, related_files.tested_files($0))
		merge_down(deserving_branch)
	end #if
end #script_deserves_commit!
def test(executable=@related_files.model_test_pathname?)
	merge_conflict_recovery
	@repository.safely_visit_branch(:master) do |changes_branch|
		begin
			deserving_branch=deserving_branch?(executable)
			if deserving_branch != :passed then #master corrupted
				edit
				done=false
			else
				done=true
			end #if
		end until done
		@repository.confirm_commit(:interactive)
#		@repository.validate_commit(changes_branch, @related_files.tested_files(executable))
	end #safely_visit_branch
	begin
		deserving_branch=deserving_branch?(executable)
		puts deserving_branch if $VERBOSE
		@repository.safely_visit_branch(deserving_branch) do |changes_branch|
			@repository.validate_commit(changes_branch, @related_files.tested_files(executable))
		end #safely_visit_branch
		merge_down(deserving_branch)
		@repository.recent_test.puts
		edit
		if @repository.something_to_commit? then
			done=false
		else
			if deserving_branch == @repository.current_branch_name? then
				done=true # branch already checked
			else
				done=false # check other branch
				@repository.confirm_branch_switch(deserving_branch)
				puts "Switching to deserving branch"+deserving_branch.to_s
			end #if
		end #if
	end until done
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

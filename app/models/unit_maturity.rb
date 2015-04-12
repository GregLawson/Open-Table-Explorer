###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/no_db.rb'
#assert_global_name(:Repository)
require_relative '../../app/models/branch.rb'
class UnitMaturity
#include Repository::Constants
module Constants
#assert_global_name(:Repository)
#include Repository::Examples
Branch_enhancement = [:passed, :testing, :edited] # higher inex means more enhancements/bugs
Extended_branches = { -4 => :'origin/master',
	-3 => :work_flow,
	-2 => :tax_form,
	-1 => :master }
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
end #Constants
include Constants
module ClassMethods
#include Repository::Constants
include Constants
def branch_symbol?(branch_index)
	case branch_index
	when nil then fail 'branch_index=' + branch_index.inspect
	when -4 then :'origin/master'
	when -3 then :work_flow
	when -2 then :tax_form
	when -1 then :master
	when 0..UnitMaturity::Branch_enhancement.size - 1 then UnitMaturity::Branch_enhancement[branch_index]
	when UnitMaturity::Branch_enhancement.size then :stash
	else
		('stash~' + (branch_index - UnitMaturity::Branch_enhancement.size).to_s).to_sym
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
end #ClassMethods
extend ClassMethods
attr_reader :repository, :unit
def initialize(repository, unit)
	fail "UnitMaturity.new first argument must be of type Repository" unless repository.instance_of?(Repository)
#	fail "@repository must respond to :remotes?\n"+
#		"repository.inspect=#{repository.inspect}\n" +
#		"repository.methods(false)=#{repository.methods(false).inspect}" unless repository.respond_to?(:remotes?)
	@repository=repository
	@unit = unit
end # initialize
def diff_command?(filename, branch_index)
	fail filename + ' does not exist.' if !File.exists?(filename)
	branch_string = UnitMaturity.branch_symbol?(branch_index).to_s
	git_command = "diff --summary --shortstat #{branch_string} -- " + filename
	diff_run = @repository.git_command(git_command)
end # diff_command?
def reflog?(filename)
	reflog_run = @repository.git_command("reflog  --all --pretty=format:%gd,%gD,%h -- " + filename)
	reflog_run.assert_post_conditions
	lines = reflog_run.output.split("\n")
	lines.map do |line|
		refs = line.split(',')
		if refs[0] == '' then
			refs[2] # hash
		else
			refs[0] # unambiguous ref
		end # if
	end # map
end # reflog?
def last_change?(filename)
	reflog?(filename)[0]
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
def rebase!
	if remotes?.include?(current_branch_name?) then
		git_command('rebase --interactive origin/'+current_branch_name?).assert_post_conditions.output.split("\n")
	else
		puts current_branch_name?.to_s+' has no remote branch in origin.'
	end #if
end #rebase!
module Examples
include Constants
File_not_in_oldest_branch = 'test/long_test/repository_test.rb'
Most_stable_file = 'test/unit/minimal2_test.rb'
Formerly_existant_file = 'test/unit/related_file.rb'
TestUnitMaturity = UnitMaturity.new(Repository::This_code_repository, Repository::Repository_Unit)
end # Examples
end # UnitMaturity

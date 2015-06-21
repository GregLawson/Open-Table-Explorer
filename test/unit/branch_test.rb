###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../test/assertions/branch_assertions.rb'
#require_relative '../../test/assertions/repository_assertions.rb'
require_relative '../../app/models/branch.rb'
class BranchTest < TestCase
include DefaultTests
include Repository::Examples
include Branch::Constants
include BranchReference::Examples
include Branch::Examples
def setup
	@temp_repo = Repository.create_test_repository(@temp_repo_path)
end # setup
def teardown
	ShellCommands.new('rm -rf ' + @temp_repo.path)
end # teardown
include BranchReference::Constants
def test_BranchReference_Constants
	BranchReference.assert_reflog_line(Reflog_line)
	BranchReference.assert_reflog_line(Last_change_line)
	BranchReference.assert_capture(Reflog_line)
	BranchReference.assert_capture(Last_change_line)
	BranchReference.assert_capture(First_change_line)
	Reflog_lines.each do |reflog_line|
		BranchReference.assert_capture(reflog_line)
	end # each
end #Constants
def test_new_from_ref
	BranchReference.assert_capture(Reflog_line)
	BranchReference.assert_capture(Last_change_line)
	reflog_line = No_reflog_line
	capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
	br = BranchReference.new_from_ref(reflog_line)
	refs = reflog_line.split(',')
	assert_equal(refs[0], '', capture.inspect)
	assert_equal(refs[2].to_sym, br.branch, br.inspect)
	assert_equal(Time.rfc2822(refs[4]), br.timestamp, br.inspect) #
	reflog_line = Last_change_line
	capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
	br = BranchReference.new_from_ref(reflog_line)
	refs = reflog_line.split(',')
	assert_not_equal(refs[0], '', capture.inspect)
#			BranchReference.new_from_ref(refs[0]), :time => refs[3]} # unambiguous ref
	assert_equal(refs[0], br.branch, br.inspect)
	assert_equal(refs[3], br.timestamp, br.inspect)
	branch = :master
	age = 123	
	br = BranchReference.new(branch: branch, age: age)
	new_from_ref = BranchReference.new_from_ref(Reflog_line)
	assert_equal('123', new_from_ref.age, Reflog_capture.output?.inspect)
	assert_equal('123', new_from_ref[:age], Reflog_capture.inspect)
	assert_equal(br, BranchReference.new_from_ref(Reflog_line))
end # new_from_ref
def test_reflog?
#	reflog?(filename).output.split("/n")[0].split(',')[0]
	filename = $0
	reflog_run = This_code_repository.git_command("reflog  --all --pretty=format:%gd,%gD,%h,%aD -- " + filename)
	Reflog_run_executable.assert_post_conditions
	lines = Reflog_run_executable.output.split("\n")
	Reflog_lines.map do |reflog_line|
		BranchReference.assert_reflog_line(reflog_line)
#		new(capture.output?[:ambiguous_branch].to_sym,capture.output?[:age].to_i)

	end # map
	reflog = BranchReference.reflog?(filename, This_code_repository)
#	reflog.assert_post_conditions
#	assert_not_empty(reflog.output)
##	lines = reflog.output.split("\n")
#	assert_instance_of(Array, reflog)
#	assert_operator(reflog.size, :>,1, reflog)
#	assert_equal('', reflog[0], lines)
end # reflog?
def test_last_change?
	filename = $0
	repository = @temp_repo
	reflog = BranchReference.reflog?(filename, repository)
	assert_equal(nil, BranchReference.last_change?(filename, repository))
	assert_includes([], BranchReference.last_change?(filename, This_code_repository).branch)
end # last_change?
def test_assert_reflog_line
	BranchReference.assert_reflog_line(Reflog_line)
	BranchReference.assert_reflog_line(Last_change_line)
	BranchReference.assert_reflog_line(First_change_line)
	BranchReference.assert_reflog_line(No_reflog_line)
end # reflog_line
def test_assert_capture
	BranchReference.assert_capture(Reflog_line)
	BranchReference.assert_capture(Last_change_line)
	BranchReference.assert_capture(First_change_line)
	BranchReference.assert_capture(No_reflog_line)
end # assert_capture
def test_Branch_Constants
end #Constants
def test_branch_capture
	repository = @temp_repo
	git_command = 'branch --list'
	branch_output = repository.git_command(git_command).assert_post_conditions.output
	parse = branch_output.parse(Branch_regexp)
end # branch_capture?
def test_current_branch_name?
#	assert_include(UnitMaturity::Branch_enhancement, WorkFlow.current_branch_name?, Repo.head.inspect)
	branch_output= @temp_repo.git_command('branch --list').assert_post_conditions.output
	assert_equal([:master, :passed], Branch.current_branch_name?(@temp_repo))
end #current_branch_name
def test_branches?
#?	explain_assert_respond_to(Parse, :parse_split)
	branch_output = @temp_repo.git_command('branch --list').assert_post_conditions.output
	Patterns.each do |p|
		assert_match(p, branch_output)
		branches = branch_output.capture?(p, LimitCapture)
		puts branches.inspect if branches.success?
		assert_equal([{:branch=>"master"}, {:branch=>"passed"}], branches.output?, branches.inspect)
	end # each
	
	assert_includes(Branch.branches?(@temp_repo).map{|b| b.branch}, @temp_repo.current_branch_name?)
	assert_equal([:master, :passed], Branch.branches?(@temp_repo).map{|b| b.branch})
	assert_includes(Branch.branch_names?(This_code_repository), This_code_repository.current_branch_name?)
end #branches?
def test_remotes?
	assert_empty(Branch.remotes?(@temp_repo))
	assert_not_empty(Branch.remotes?(This_code_repository))
end # remotes?
def test_merged?
	assert_equal({:merged=>"passed"}, Branch.merged?(@temp_repo))
	assert_not_empty(Branch.merged?(This_code_repository))
end # merged?
def test_initialize
	assert_equal(This_code_repository, Branch.new(This_code_repository).repository)

	branch=This_code_repository.current_branch_name?
	onto=Branch::Examples::Executing_branch.find_origin
end # initialize
end # Branch

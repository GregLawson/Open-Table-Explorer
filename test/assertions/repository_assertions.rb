###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# @see http://grit.rubyforge.org/
require_relative '../../app/models/repository.rb'
class Repository <Grit::Repo
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
	assert_pathname_exists(@path)
	assert_pathname_exists(@path+'.git/')
	assert_pathname_exists(@path+'.git/logs/')
	assert_pathname_exists(@path+'.git/logs/refs/')
	assert_include(Minimal_repository.methods, :unit_names?)
#	assert_include(Minimal_repository.methods(false), :unit_names?)
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
def assert_nothing_to_commit(message='')
	status=@grit_repo.status
	message+="git status=#{inspect}\n@grit_repo.status=#{@grit_repo.status.inspect}"
	assert_equal({}, status.added, 'added '+message)
	assert_equal({}, status.changed, 'changed '+message)
	assert_equal({}, status.deleted, 'deleted '+message)
end #assert_nothing_to_commit
def assert_something_to_commit(message='')
	message+="git status=#{inspect}\n@grit_repo.status=#{@grit_repo.status.inspect}"
	assert(something_to_commit?, message)
end #assert_something_to_commit
def assert_deserving_branch(branch_expected, executable, message='')
	deserving_branch=deserving_branch?(executable)
	recent_test=shell_command(["ruby", executable])
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
Repository.assert_pre_conditions
module Examples
include Constants
Removable_Source='/media/greg/SD_USB_32G/Repository Backups/'
#Repo= Grit::Repo.new(Root_directory)
#SELF_code_Repo=Repository.new(Root_directory)
Empty_Repo_path=Source+'test_repository/'
Empty_Repo=Repository.create_test_repository(Empty_Repo_path)
Modified_path=Empty_Repo_path+'/README'
Unique_repository_directory_pathname=RelatedFile.new('test').data_sources_directory?+Time.now.strftime("%Y-%m-%d %H:%M:%S.%L")

end #Examples
end #Repository



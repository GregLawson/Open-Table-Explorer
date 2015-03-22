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
end #Assertions
include Assertions
extend Assertions::ClassMethods
Repository.assert_pre_conditions
module Examples
include Constants
	This_code_repository.assert_pre_conditions
Removable_Source='/media/greg/SD_USB_32G/Repository Backups/'
#Repo= Grit::Repo.new(Root_directory)
SELF_code_Repo=Repository.new(Root_directory)
Empty_Repo_path=Source+'test_repository/'
Empty_Repo=Repository.create_test_repository(Empty_Repo_path)
Modified_path=Empty_Repo_path+'/README'
Unique_repository_directory_pathname = Repository.timestamped_repository_name?
	This_code_repository.assert_pre_conditions
end #Examples
end #Repository



###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/no_db.rb'
require_relative 'repository.rb'
# reopen for patch
class Repository
def branches?
	branch_output=git_command('branch --list').assert_post_conditions.output
#?	Parse.parse_into_array(branch_output, /[* ]/*/[a-z0-9A-Z_-]+/.capture*/\n/, ending=:optional)
end #branches?
def remotes?
	git_command('branch --list --remote').assert_post_conditions.output.split("\n")
end #remotes?
end # Repository
class Branch
include Repository::Constants
module ClassMethods
include Repository::Constants
def this_code?
end # this_code?
end #ClassMethods
extend ClassMethods
def find_origin
	if @repository.remotes?.include?(@repository.current_branch_name?) then
		'origin/'+@branch.to_s
	else
		nil
	end #if
end # find_origin
attr_reader :repository, :branch, :remote_branch
def initialize(repository=This_code_repository, branch=repository.current_branch_name?, remote_branch=nil)
	@repository=repository
	@branch=branch
	if remote_branch.nil? then
		@remote_branch=find_origin
	else
		@remote_branch=remote_branch
	end # if
end # initialize
module Constants
Executing_branch=Branch.new
end #Constants
include Constants
module Examples
include Constants
	
end #Examples
end # Branch

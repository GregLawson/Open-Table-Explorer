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
Branch_regexp=/[* ]/*/ /*/[-a-z0-9A-Z_]+/.capture(:branch)
def shell_parse(command, pattern)
	output=git_command(command).assert_post_conditions.output
	parse=Parse.parse_into_array(output, pattern, {ending: :optional})
end # 
def branches?
	branch_output=git_command('branch --list').assert_post_conditions.output
	parse=Parse.parse_into_array(branch_output, Branch_regexp, {ending: :optional})
	parse.map {|e| Branch.new(self, e[:branch].to_sym)}
end #branches?
def remotes?
	pattern=/  /*(/[a-z0-9\/A-Z]+/.capture(:remote))
	shell_parse('branch --list --remote', pattern)
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
# Allows Branch objects to be used in most contexts where a branch name Symbol is expected
def to_s
	@branch
end # to_s
module Constants
Executing_branch=Branch.new
Branch_regexp=/[* ]/*/ /*/[-a-z0-9A-Z_]+/.capture(:branch)
end #Constants
include Constants
module Examples
include Constants
	
end #Examples
end # Branch

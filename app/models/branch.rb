###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/no_db.rb'
#require_relative '../../test/assertions/repository_assertions.rb'
#assert_global_name(:Repository)
require_relative '../../app/models/parse.rb'
class Branch
#include Repository::Constants
module Constants
#assert_global_name(:Repository)
#include Repository::Examples
Branch_name_regexp = /[-a-z0-9A-Z_]+/
Branch_name_alternative = [Branch_name_regexp.capture(:branch)]
Pattern = /[* ]/*/[a-z0-9A-Z_-]+/.capture(:branch)*/\n/
Git_branch_line = [/[* ]/, / /, Branch_name_regexp.capture(:branch)]
Git_branch_remote_line = [/[* ]/, / /, Branch_name_alternative]
Branch_regexp = /[* ]/*/ /*/[-a-z0-9A-Z_]+/.capture(:branch)
Branches_regexp = Branch_regexp.group * Regexp::Many
Patterns = [Pattern, Branches_regexp,
				/[* ]/*/ /*/[-a-z0-9A-Z_]+/.capture(:branch),
				/^[* ] /*/[a-z0-9A-Z_-]+/.capture(:branch)
				]
end #Constants
include Constants
module ClassMethods
#include Repository::Constants
include Constants
def branch_command?(repository, git_command)
	branch_output = repository.git_command(git_command).assert_post_conditions.output
	parse = branch_output.parse(Branch_regexp)
end # branch_command?
def current_branch_name?(repository)
	branch_output= repository.git_command('branch --list').assert_post_conditions.output
	parse = branch_output.parse(Branch_regexp)
	parse[:branch].to_sym
end #current_branch_name
def branches?(repository)
	branch_output = branch_command?(repository, 'branch --list').assert_post_conditions.output
	parse = branch_output.parse(Branch_regexp)
	parse.map {|e| Branch.new(self, e[:branch].to_sym)}
end #branches?
def remotes?
	pattern=/  /*(/[a-z0-9\/A-Z]+/.capture(:remote))
	git_parse('branch --list --remote', pattern).map{|h| h[:remote]}
end #remotes?
def new_from_git_branch_line(git_branch_line)

end # new_from_git_branch_line
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
def initialize(repository, branch=repository.current_branch_name?, remote_branch=nil)
	fail "Branch.new first argument must be of type Repository" unless repository.instance_of?(Repository)
#	fail "@repository must respond to :remotes?\n"+
#		"repository.inspect=#{repository.inspect}\n" +
#		"repository.methods(false)=#{repository.methods(false).inspect}" unless repository.respond_to?(:remotes?)
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
	@branch.to_s
end # to_s
def to_sym
	@branch.to_sym
end # to_s
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end # Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
end # Examples
end # Branch

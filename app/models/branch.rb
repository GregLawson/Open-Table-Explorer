###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/no_db.rb'
#require_relative 'repository.rb'
class Branch
#include Repository::Constants
module ClassMethods
#include Repository::Constants
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
	@branch
end # to_s
module Constants
end #Constants
include Constants
end # Branch

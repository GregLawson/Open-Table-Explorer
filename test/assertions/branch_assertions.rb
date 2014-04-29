###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../test/assertions/repository_assertions.rb' # get Examples
require_relative '../../app/models/branch.rb' # get Examples
class Branch
#include Repository::Constants
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
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
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
Empty_repo_master_branch=Branch.new( Repository::Examples::Empty_Repo, :master)
Executing_branch=Branch.new(Repository::Examples::This_code_repository)
Executing_master_branch=Branch.new(Repository::Examples::This_code_repository, :master)
end #Examples
end # Branch

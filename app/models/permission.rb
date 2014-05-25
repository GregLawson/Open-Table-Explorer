###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/no_db.rb'
class Permission < Pathname
module ClassMethods
end #ClassMethods
extend ClassMethods
module Constants
end #Constants
include Constants
# attr_reader
def initialize(pathname)
	super(pathname)
end #initialize
def touch_rescued!
	FileUtils.touch(probe_path)
	true # returned if success (updated times or created)
rescue Exception => exception
	exception
end # touch_rescued
# Should clean up side effects of touch_rescued!
def creatable_rescued?(probe_name = 'junk')
	if directory? then
		probe_path = self + probe_name
	else
		probe_path = self
	end # if
	if File.exists?(probe_path) then
		touch_rescued!(probe_path)
	else
		ret = touch_rescued!(probe_path)
		File.rm(probe_path) # if succesfully created
		ret

	end # if
end # creatable_rescued?
require_relative '../../test/assertions.rb'
module Assertions
#include Minitest::Assertions
module ClassMethods
#include Minitest::Assertions
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
Example_no_write = Permission.new('/media/central/Non-media/Git_repositories/Open-Table-Explorer/.git/./objects/pack/tmp_pack_XXXXXX')
end #Examples
end # Permission

###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/permission.rb'
require_relative '../../app/models/shell_command.rb'
class PermissionTest < TestCase
include DefaultTests
include TE.model_class?::Examples
def test_touch_rescued!
end # touch_rescued
def test_creatable_rescued?(probe_name = 'junk')
end # creatable_rescued?
def test_Examples
#	assert_pathname_exists(Example_no_write)
	Example_no_write.ascend do |ancestral_pathname| 
		if ancestral_pathname.directory? then
			probe_path = ancestral_pathname + 'junk'
			if File.exists?(probe_path) then
				FileUtils.touch(probe_path)
			else begin
			
				FileUtils.touch(probe_path)
				File.rm(probe_path) # if succesfully created
				rescue Exception => exception
				
			end end # if
		end # if
		p ancestral_pathname.inspect + ' ' + ancestral_pathname.writable?.to_s
	end # ascend
end # Examples
end # Permission

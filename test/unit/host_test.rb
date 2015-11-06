###########################################################################
#    Copyright (C) 2011-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/host.rb'
# executed in alphabetical order. Longer names sort later.
class HostTest < TestCase
#include DefaultTests
include Unit::Executable.model_class?::Examples
def test_Constants

end # Constants
def test_recordDetection
	ip = '192.168.0.'
	timestamp=Time.new
end
end #Host

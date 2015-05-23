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
include TE.model_class?::Examples
def test_Constants
end # Constants
def test_nmap
	ip_range = '192.168.0.1-254'
	nmap_run = ShellCommand.new('nmap ' + ip_range).assert_post_conditions
	nmap_hash = nmap_run.output.parse(Start_line)
end # nmap
def test_nmapScan
#	candidateIP = 
#	assert_test_id_equal
end # nmapScan
end #Host

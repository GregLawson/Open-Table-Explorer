###########################################################################
#    Copyright (C) 2012-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/partition.rb'
class PartitionTest < TestCase
#include DefaultTests
include Unit::Executable.model_class?::Examples
def test_initialize

	partition_run=ShellCommands.new('cat /proc/partitions').assert_pre_conditions
	partition_run.output
end # initialize
end # Partition

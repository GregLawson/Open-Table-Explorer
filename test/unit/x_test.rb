###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/x.rb'
class XTest < TestCase
include DefaultTests
include TE.model_class?::Examples
def test_logs
  logs = Dir['/var/log/X*']
  assert_not_empty(logs)
end # logs
def test_log
  logs = Dir['/var/log/X*']
  log_file = logs[0]
  log = IO.read(log_file)
  assert_not_empty(log)
end # log
end #Minimal

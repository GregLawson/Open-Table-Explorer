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
  assert_not_empty(Logs)
  
end # logs
def test_log
  log_file = Logs[0]
  log = IO.read(log_file)
  assert_not_empty(log)
  assert_equal({sequence: '1'}, Parse.parse_string('/var/log/Xorg.1.log', Prefix * Sequence))
  assert_equal({sequence: '1'}, Parse.parse_string('/var/log/Xorg.1.log', Prefix * Sequence * /.log/))
  assert_equal({sequence: '1', old: nil}, Parse.parse_string('/var/log/Xorg.1.log', Prefix * Sequence * /.log/ * Suffix.group * Optional))
  assert_equal({sequence: '1', old: nil}, Parse.parse_string('/var/log/Xorg.1.log', File_pattern))
end # log
end # X

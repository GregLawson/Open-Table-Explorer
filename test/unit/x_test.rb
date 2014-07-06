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
#  assert_equal([{time: 0.0}], Parse.parse(Test_lines, Time_seconds), Test_lines.inspect)
  assert_instance_of(Float, Test_lines.parse(Time_regexp)[:time].to_f, Test_lines.inspect)
  assert_instance_of(String, Source_explanation[log.parse(Source_alternatives)[:source]], Test_lines.inspect)
#  assert_equal([{message: ''}], Parse.parse(Test_lines, Message_regexp), Test_lines.inspect)
#  assert_operator(2, :<=, Parse.parse(Test_lines, Log_pattern).size, Test_lines.inspect)
  assert_not_empty(log)
  assert_equal({sequence: '1'}, '/var/log/Xorg.1.log'.parse(Prefix * Sequence))
  assert_equal({sequence: '1'}, '/var/log/Xorg.1.log'.parse(Prefix * Sequence * /.log/))
  assert_equal({sequence: '1', old: nil}, '/var/log/Xorg.1.log'.parse(Prefix * Sequence * /.log/ * Suffix.group * Optional))
  assert_equal({sequence: '1', old: nil}, '/var/log/Xorg.1.log'.parse(File_pattern))
  assert_equal({sequence: '1', old: '.old'}, '/var/log/Xorg.1.log.old'.parse(File_pattern))
  assert_equal({sequence: '1', old: '.old'}, Parse.parse_string('/var/log/Xorg.1.log.old', File_pattern))
end # log
end # X

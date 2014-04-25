###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/parse.rb'
class X
module ClassMethods
def logs
  logs = Dir['/var/log/X*']
end # logs
end #ClassMethods
extend ClassMethods
module Constants
include Regexp::Constants
Logs = X::logs
Prefix = %r{/var/log/Xorg.}
Sequence = /[0-9]+/.capture(:sequence)
Suffix = /\.old/.capture(:old)
File_pattern = Prefix * Sequence * /.log/ * Suffix.group * Optional
Time_seconds = /[0-9]+\.[0-9]{3}/.capture(:time)
Time_regexp = /^\[/ * /[ ]{0,6}/ * Time_seconds * /\] /
Source_explanation = {'--' => 'probed',
 '**' => 'from config file',
 '==' => 'default setting',
 '++' => 'from command line',
 '!!' => 'notice',
 'II' => 'informational',
 'WW' => 'warning',
 'EE' => 'error',
 'NI' => 'not implemented',
 '??' => 'unknown'}
Source_alternatives = Source_explanation.keys.map {|s| Regexp.new(Regexp.escape(s))}.reduce(:|).capture(:source)
Source_regexp = /\(/ * Source_alternatives * /\) /
Message_regexp = /[^\n]*/.capture(:message)
Log_pattern = Time_regexp * Source_regexp * Optional * Message_regexp
end #Constants
include Constants
# attr_reader :sequence, :old
def initialize(log_file)
  @log_file = log_file
  @parse_filename = Parse.parse_string(log_file, File_pattern)
  @sequence = @parse_filename[:sequence].to_i
  @old = @parse_filename[:old] ? true : false
  assert_equal({sequence: '1', old: '.old'}, Parse.parse_string('/var/log/Xorg.1.log.old', File_pattern))
  @log = IO.read(@log_file)
end #initialize
def log
  logs = Dir['/var/log/X*']
  log_file = logs[0]

end # log
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
Test_lines = IO.read('/var/log/Xorg.1.log')[0..800]
end #Examples
end # X

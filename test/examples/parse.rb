###########################################################################
#    Copyright (C) 2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/parse.rb'
class MatchRefinementTest < TestCase
	
	module Examples
		A_leftover = MatchRefinement['a']
		A_mismatch = MatchRefinement[MatchCapture.new(string: 'b', regexp: /a/)]
		B_capture = MatchCapture.new(string: 'b', regexp: /b/)
		B_match = MatchRefinement[B_capture]
		AB = MatchRefinement['a', B_capture]
		ABC_match_b = MatchRefinement['a', B_capture, 'c']
		BA = MatchRefinement[B_capture, 'a']
		Scattered_match = MatchRefinement[B_capture, 'c', B_capture]
	end # Examples
	include Examples
end # MatchRefinement

class NameValueParseTest < TestCase
	module Examples
		include NameValueParse::DefinitionalConstants
		Name_value_pair_string = 'a=1'
		Name_value_pair_capture = MatchCapture.new(string: Name_value_pair_string, regexp: Name_value_pair_array)
	end # Examples
	include Examples
end # NameValueParse

class CaptureTest < TestCase
	module Examples
		Reflog_timestamp = 'Sun, 21 Jun 2015 13:51:50 -0700'.freeze

	end # Examples
	include Examples
	module Examples
    Match_a = { /(?<alpha>a)/ => [{ alpha: 'a' }] }.freeze
    Match_b = { /(?<beta>b)/ => [{ beta: 'b' }] }.freeze
    Unmatched_c = 'c'.freeze
    Ordered_matches = [Match_a, Match_b, Unmatched_c].freeze
		Empty_capture = MatchCapture.new(string: '', regexp: /a/)
		
		include TimeTypes
		include ReflogRegexp
    SHA1_hex_7 = /[[:xdigit:]]{7}/.capture(:sha1_hex_7)
    Reflog_line = 'master@{123},refs/heads/master@{123},1234567,Sun, 21 Jun 2015 13:51:50 -0700'.freeze
    Reflog_capture = Reflog_line.capture?(Reflog_line_regexp)
		
    No_ref_line = ',,911dea1,Sun, 21 Jun 2015 13:51:50 -0700'.freeze
    Stash_line = 'stash@{0},refs/stash@{0},bec64c4cd,Mon, 20 Mar 2017 11:55:03 -0700'.freeze
		Regexp_array_capture = MatchCapture.new(string: Stash_line, regexp: Regexp_array)
		
		Fail_array = Regexp_array[0..3] + [SHA1_hex_7] + Regexp_array[5..-1]
		Scattered_array_capture = MatchCapture.new(string: Stash_line, regexp: Fail_array)
		All_captures = [Empty_capture, MatchRefinementTest::Examples::B_capture, Reflog_capture, Regexp_array_capture, Scattered_array_capture, NameValueParseTest::Name_value_pair_capture]
	end # Examples
	include Examples
end # Capture

class Capture
  module Examples
    Newline_Delimited_String = "* 1\n  2".freeze
    Newline_Terminated_String = Newline_Delimited_String + "\n"
    Branch_current_regexp = /[* ]/.capture(:current) * / / * /[-a-z0-9A-Z_]+/.capture(:branch)
    Branch_regexp = /[* ]/ * / / * /[-a-z0-9A-Z_]+/.capture(:branch)
    Branch_line_regexp = Branch_regexp * "\n"
    Current_variable = GenericVariable .new(name: 'current')
    Branch_variable = GenericVariable .new(name: 'branch')
    Current_column = GenericColumn.new(regexp_index: 0, variable: Current_variable)
    Branch_column = GenericColumn.new(regexp_index: 0, variable: Branch_variable)
    Branch_column_value = { Branch_column => '1' }.freeze
    Branch_column_answer = { Branch_column => '1' }.freeze
    Branch_answer = { branch: '1' }.freeze
    LINE = /[^\n]*/.capture(:line)
    Line_terminator = /\n/.capture(:terminator)
    Terminated_line = (LINE * Line_terminator).group
    Hash_answer = { line: '* 1', terminator: "\n" }.freeze
    Array_answer = [{ line: '* 1', terminator: "\n" }, { line: '  2', terminator: "\n" }].freeze
    Branch_hashes = [{ current: '*', branch: '1' }, { current: ' ', branch: '2' }].freeze

    WORD = /([^\s]*)/.capture(:word)
  end # Examples
end # Capture

class BisectionTest < TestCase
end # Bisection

class MatchCapture < RawCapture
  module Examples
    include Capture::Examples
    Branch_capture = MatchCapture.new(string: Newline_Delimited_String, regexp: Branch_regexp)
    Parse_string = MatchCapture.new(string: Newline_Delimited_String, regexp: Branch_regexp)
    Branch_line_capture = MatchCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
    Branch_current_capture = MatchCapture.new(string: Newline_Delimited_String, regexp: Branch_current_regexp)
    Empty_capture = MatchCapture.new(string: '', regexp: /a/)
		Abc_match_abc = MatchCapture.new(string: 'abc', regexp: /abc/)
		Abc_match_a = MatchCapture.new(string: 'abc', regexp: /a/)
		Abc_match_b = MatchCapture.new(string: 'abc', regexp: /b/)
		Abc_match_c = MatchCapture.new(string: 'abc', regexp: /c/)

		No_match = MatchCapture.new(string: 'abc', regexp: /d/)
		No_match_array = MatchCapture.new(string: 'abc', regexp: [/d/, /e/])
  end # Examples
end # MatchCapture

class SplitCapture < RawCapture
  module Examples
    include Capture::Examples
    Split_capture = SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
    Parse_array = SplitCapture.new(string: Newline_Terminated_String, regexp: Branch_regexp)
    Branch_line_capture = SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
    Branch_regexp_capture = SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_regexp)
    Failed_capture = SplitCapture.new(string: 'cat', regexp: /fish/)
    Syntax_failed_capture = SplitCapture.new(string: 'cat', regexp: 'f)i]s}h')
    Parse_delimited_array = SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_regexp)
    Empty_capture = SplitCapture.new(string: '', regexp: /a/)
  end # Examples
end # SplitCapture

class ParsedCapture < MatchCapture
  module Examples
    include Capture::Examples
    # Branch_line_capture = ParsedCapture.new(Newline_Delimited_String, Branch_line_regexp)
    Parsed_a_capture = ParsedCapture.new(string: 'a,a,', regexp: /a{2}/.capture(:label))
    Parsed_aa_capture = ParsedCapture.new(string: 'a,a,', regexp: /a,/.capture(:label) * 2)
    Match_a = { /(?<alpha>a)/ => [{ alpha: 'a' }] }.freeze
    Match_b = { /(?<beta>b)/ => [{ beta: 'b' }] }.freeze
    Unmatched_c = 'c'.freeze
    Ordered_matches = [Match_a, Match_b, Unmatched_c].freeze
  end # Examples
end # ParsedCapture
class LimitCapture < ParsedCapture
  module Examples
    include Capture::Examples
    Branch_line_capture = LimitCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
    Limit_capture = LimitCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
  end # Examples
end # LimitCapture

class String
  module Examples
    include Constants
    include Regexp::DefinitionalConstants
    LINES_cryptic = /([^\n]*)(?:\n([^\n]*))*/
    CSV = /([^,]*)(?:,([^,]*?))*?/
    Ls_octet_pattern = /rwx/
    Ls_permission_pattern = [/1|l/,
                             Ls_octet_pattern.capture(:system_permissions),
                             Ls_octet_pattern.capture(:group_permissions),
                             Ls_octet_pattern.capture(:owner_permissions)].freeze
    Filename_pattern = /[-_0-9a-zA-Z\/]+/
    Driver_pattern = [
      /\s+/, /[0-9]+/.capture(:permissions),
      /\s+/, /[0-9]+/.capture(:size),
      / /, Ls_permission_pattern,
      /\s+/, /[a-z]+/.capture(:owner),
      /\s+/, /[a-z]+/.capture(:group),
      /\s+/, /[0-9]+/.capture(:size_2),
      /\s+/, /[A-Za-z]+/.capture(:month),
      /\s+/, /[0-9]+/.capture(:date),
      /\s+/, /[0-9]+/.capture(:time),
      /\s+/, '/sys/devices',
      Filename_pattern.capture(:device),
      ' -> ',
      Filename_pattern.capture(:driver)].freeze
    Driver_string = '  7771    0 lrwxrwxrwx   1 root     root            0 Jul 27 08:20 /sys/devices/pnp0/00:0d/driver -> ../../../bus/pnp/drivers/ns558'.freeze
  end # Examples
end # String

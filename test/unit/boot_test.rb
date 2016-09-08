###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/boot.rb'
class BootTest < TestCase
  # include DefaultTests
  # include RailsishRubyUnit::Executable.model_class?::Examples
  include Boot::Examples

  def assert_repeat_match(regexp, target_matches)
    matches = Grubs_run.output.split(Terminator).size
    capture = Grubs_run.output.capture?(regexp, SplitCapture)
    assert_equal([:@string, :@regexp, :@raw_captures], capture.instance_variables)

    assert_include(capture.methods, :delimiters)
    assert_include(capture.methods, :success?)
    refute_nil(capture.raw_captures, capture.inspect)
    max_record_length = 300
    assert_match(regexp, Grubs_run.output[0,max_record_length])
    assert_operator(2, :<=, capture.raw_captures.size, capture.inspect)
    message = capture.raw_captures[1][0..100].inspect
    assert_match(regexp, One_menu_entry, message)
    
    
    assert_equal(target_matches, capture.raw_captures.size, message)
    capture # for further processing
  end # repeat_match
  
  def test_Minimal_DefinitionalConstants
    assert_match(/[N1-5] [1-5]\n/, Run_levels.output, Run_levels.inspect)
    assert_include(["degraded\n", "offline\n"], Is_system_running.output, Is_system_running.inspect)
    assert_equal("Linux acer-desktop 4.6.0-1-rt-amd64 #1 SMP PREEMPT RT Debian 4.6.4-1 (2016-07-18) x86_64 GNU/Linux\n", Uname.output, Uname.inspect)
    assert_repeat_match(Uuid_regexp, 193)
    assert_match(Classes_regexp, Grubs_run.output, Grubs_run.inspect)
    assert_match(Boot_line_regexp, One_menu_entry, One_menu_entry.inspect)
    assert_match(Boot_line_regexp, Grubs_run.output, Grubs_run.inspect)
    assert_repeat_match(Linux_version_regexp, 721)
    assert_repeat_match(Vmlinuz_regexp, 505)
    assert_repeat_match(Paranthetic_title_regexp, 81)
    assert_repeat_match(/\tlinux /, 45)
    assert_repeat_match(Regexp::Start_string * Boot_line_regexp, 10)
    assert_repeat_match(/^/ * Boot_line_regexp, 397)
#    assert_repeat_match(Menu_title_regexp, 60)
  end # DefinitionalConstants

  def remove_matches(regexp_array)
    unmatches = [Grubs_run.output]
    regexp_array.each do |regexp_symbol|    
      unmatches = unmatches.map do |unmatched|
        regexp = eval(regexp_symbol.to_s)
        capture = unmatched.capture?(regexp, SplitCapture)
        capture.delimiters
      end.flatten # map
    end # each regexp
  end # remove_matches

	def test_state
		
	end # state
	
  def test_Minimal_Virtus
  end # values

  def test_Minimal_assert_pre_conditions
  end # assert_pre_conditions

  def test_Minimal_assert_post_conditions
  end # assert_post_conditions

  def assert_pre_conditions
  end # assert_pre_conditions

  def assert_post_conditions
  end # assert_post_conditions

  def test_Minimal_Examples
  end # Examples
end # Boot

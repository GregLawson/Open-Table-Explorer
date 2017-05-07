###########################################################################
#    Copyright (C) 2012-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/minimal2.rb'
class Minimal2Test < TestCase
  # include DefaultTests
  #  include RailsishRubyUnit::Executable.model_class?::Examples
  module Examples
  end #  Examples
  include Examples

  # rubocop:disable Style/MethodName
  def test_Minimal_DefinitionalConstants
  end # DefinitionalConstants

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
  # rubocop:enable Style/MethodName
end # Minimal

###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/nomination.rb'
class NominationTest < TestCase
  # include DefaultTests
  #  include RailsishRubyUnit::Executable.model_class?::Examples
	def test_context
		assert_respond_to(Nomination, :stash, Nomination.methods(false))
		assert_include(Nomination.methods, :stash)
		assert_respond_to(Nomination::Self, :commit, Nomination.instance_methods(false))
		assert_include(Nomination.instance_methods(false), :commit)
	end # context
	
  module Examples
#		Self = Nomination.stash(TestExecutable::Examples::TestTestExecutable)
  end #  Examples
  include Examples

  # rubocop:disable Style/MethodName
  def test_Minimal_DefinitionalConstants
  end # DefinitionalConstants

		def test_stash
		end # stash
		
		def test_pending
		end # pending
		
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
end # Nomination

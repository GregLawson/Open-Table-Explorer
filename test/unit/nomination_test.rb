###########################################################################
#    Copyright (C) 2012-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/nomination.rb'
class NominationTest < TestCase
  # include DefaultTests
  include RailsishRubyUnit::Executable.model_class?::DefinitionalConstants
  include RailsishRubyUnit::Executable.model_class?::ReferenceObjects
	def test_context
		assert_respond_to(Nomination, :nominate, Nomination.methods(false))
		assert_include(Nomination.methods, :nominate)
		assert_respond_to(Nomination::Self, :commit, Nomination.instance_methods(false))
		assert_include(Nomination.instance_methods(false), :commit)
	end # context
	
  module Examples
#		Self = Nomination.stash(TestExecutable::Examples::TestTestExecutable)
  end #  Examples
  include Examples
  
	def setup
    @temp_repo = Repository.create_test_repository
  end # setup

  def test_recursive_delete
  end # recursive_delete

  def teardown
    Repository.delete_even_nonxisting(@temp_repo.path)
#    assert_empty(Dir[Cleanup_failed_test_paths], Cleanup_failed_test_paths)
  end # teardown

  # rubocop:disable Style/MethodName
  def test_Minimal_DefinitionalConstants
  end # DefinitionalConstants

		def test_stash
		end # stash
		
		def test_pending
			assert_instance_of(Array, Nomination.pending)
			Nomination.pending.each do |nomination|
				assert_instance_of(Nomination, nomination)
			end # each
		end # pending
		
  def test_Minimal_assert_pre_conditions
#		refute(Self.frozen?, Self.inspect)
  end # assert_pre_conditions

  def test_Minimal_assert_post_conditions
  end # assert_post_conditions

  def test_assert_pre_conditions
		assert_equal(:stash, Self.commit, Self.inspect)
		assert_equal(:unit, Self.test_type, Self.inspect)
		assert_equal(:nomination, Self.unit, Self.inspect)
#		Self.assert_pre_conditions
#		TestTestExecutable.assert_pre_conditions
  end # assert_pre_conditions

  def test_assert_post_conditions
  end # assert_post_conditions

  def test_Minimal_Examples
  end # Examples
  # rubocop:enable Style/MethodName
end # Nomination

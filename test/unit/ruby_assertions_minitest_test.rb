###########################################################################
#    Copyright (C) 2011-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_minitest.rb'
require_relative '../assertions/ruby_assertions_minitest.rb'
class RubyAssertionsMiniTestTest < TestCase
include RubyAssertions
  def test_requires
    assert_included_modules(:Fish, MiniTest::Assertions)
    assert_included_modules(:RubyAssertions, MiniTest::Assertions)
    assert(MiniTest::Assertions.included_modules.empty?, MiniTest::Assertions.included_modules)
    assert(MiniTest::Unit.included_modules.include?(:RubyAssertions), MiniTest::Unit.included_modules.inspect)
    assert_included_modules(MiniTest::Assertions, :RubyAssertions)
    assert(MiniTest::Assertions.instance_methods.include?(:assert), MiniTest::Assertions.instance_methods.inspect)
    assert(AssertionsModule.instance_methods.include?(:assert), AssertionsModule.instance_methods.inspect)
    assert(RubyAssertions.instance_methods.include?(:assert), RubyAssertions.instance_methods.inspect)
  end # requires
  def test_missing_file_message
    missing_pathname = '/root-kit/bad_stuff/exploit.sh'
    existing_data_file = '~/.gem'
    assert_empty(missing_file_message(existing_data_file))
    missing_pathname = Pathname.new(missing_pathname).expand_path
    existing_dir = nil
    missing_pathname.ascend do |f|
      (existing_dir = f) && break if f.exist?
      assert(!File.exist?(f))
    end # ascend
    assert_directory_exists(existing_dir)
    assert_match(/^parent directory \/ /, missing_file_message(missing_pathname))
  end # missing_file_message

  def test_assert_pathname_exists
    assert_pathname_exists('/dev/zero')
    bad_pathname = '/catfish'
    assert_raises(AssertionFailedError) { assert_pathname_exists(bad_pathname) }

    bad_pathname = '../../test/unit/TestIntrospection::TestEnvironment_assertions_test.rb'
    assert_raises(AssertionFailedError) { assert_pathname_exists(bad_pathname) }
  end # assert_pathname_exists

	def test_assert_raises
		assert_raises(RuntimeError) { fail 'assertion fail class name?' }
		assert_raises(AssertionFailedError) { refute_equal(1, 1) }
		assert_raises(AssertionFailedError) { assert_pathname_exists('/catfish') }
	end # assert_raises

	def test_assert_raise
		assert_raise(AssertionFailedError) { fail 'assertion fail class name?' }
		assert_raise(AssertionFailedError) { refute_equal(1, 1) }
		assert_raise(AssertionFailedError) { assert_pathname_exists('/catfish') }
	end # assert_raise

	def test_refute_raise
		refute_raise(AssertionFailedError) { fail 'assertion fail class name?' }
	end # assert_raise

	def test_refute_raises
		refute_raises(AssertionFailedError) { fail 'assertion fail class name?' }
	end # assert_raises
end # RubyAssertions

###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
class TestEnvironmentTest < TestCase
  def test_RegexpError
    regexp_string = ')'
    Regexp.new(regexp_string) # test
  rescue RegexpError => exception
    assert_instance_of(RegexpError, exception)
    assert_includes(exception.class.ancestors, Exception)
  end # AssertionFailedError

  def test_AssertionFailedError
    raise # test
  rescue Exception => exception
    assert_kind_of(Exception, exception)
    assert_includes(exception.class.ancestors, Exception)
    assert_instance_of(AssertionFailedError, exception)
  end # AssertionFailedError

  def test_ruby_assertions
    refute_empty([1])
  end # ruby_assertions
end # MinitestTest

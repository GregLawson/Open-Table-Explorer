###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# gem install mintest
require 'minitest/autorun'
require 'active_support/all'
require_relative '../../test/assertions/ruby_assertions.rb'
TestCase = MiniTest::Unit::TestCase
AssertionFailedError = RuntimeError
class MinimalTest < TestCase
  include RailsishRubyUnit::Executable.model_class?::Examples
  def test_RegexpError
    regexp_string = ')'
    Regexp.new(regexp_string) # test
  rescue RegexpError => exception
    assert_instance_of(RegexpError, exception)
    #	assert_includes(exception.class.ancestors, Exception)
  end # AssertionFailedError

  def test_AssertionFailedError
    raise # test
  rescue Exception => exception
    assert_kind_of(Exception, exception)
    #	assert_includes(exception.class.ancestors, Exception)
    assert_instance_of(AssertionFailedError, exception)
  end # AssertionFailedError
end # Minimal

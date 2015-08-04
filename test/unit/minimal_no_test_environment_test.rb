###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# gem install mintest
require "minitest/autorun"
require 'active_support/all'
#require_relative 'test_environment' # avoid recursive requires
require_relative '../../test/assertions/ruby_assertions.rb'
TestCase = MiniTest::Unit::TestCase
class MinimalTest < TestCase
#include TE.model_class?::Examples
end #Minimal

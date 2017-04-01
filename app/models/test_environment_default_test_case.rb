###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# gem install mintest
require_relative '../../app/models/test_environment_minitest.rb'
require_relative '../../app/models/default_test_case.rb'
DefaultTests = eval(RailsishRubyUnit::Executable.default_tests_module_name?)
TestCase = eval(RailsishRubyUnit::Executable.test_case_class_name?)

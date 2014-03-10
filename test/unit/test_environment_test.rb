require 'active_support/all'
require_relative '../../app/models/default_test_case.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/unit.rb'
TE=RelatedFile.new
DefaultTests=eval(TE.default_tests_module_name?)
TestCase=eval(TE.test_case_class_name?)
# AssertionFailedError=Test::Unit::AssertionFailedError
#require 'test_environment.rb'

###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment' # avoid recursive requires
require 'test/unit'
require_relative '../../app/models/default_test_case.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/related_file.rb'
TE=RelatedFile.new
DefaultTests=eval(TE.default_tests_module_name?)
TestCase=eval(TE.test_case_class_name?)
class MinimalTest < TestCase
include DefaultTests
#include TE.model_class?::Examples
end #Minimal

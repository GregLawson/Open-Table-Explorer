###########################################################################
#    Copyright (C) 2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../test/assertions/ruby_assertions.rb'
class Minimal
require_relative '../assertions/default_assertions.rb'
include Assertions
extend Assertions::ClassMethods
include TestCases
module TestCases

end #TestCases
end #Minimal

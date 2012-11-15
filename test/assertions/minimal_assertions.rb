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
module Assertions
module ClassMethods
end #ClassMethods
end #Assertions
include Assertions
extend Assertions::ClassMethods
include DefaultAssertions
extend DefaultAssertions::ClassMethods
module Examples
	Constant=1
end #Examples
end #Minimal

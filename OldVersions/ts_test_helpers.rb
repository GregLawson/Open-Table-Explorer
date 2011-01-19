###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit'
require 'active_record'

class A
def A.classMethodA
	return 1
end #def
def methA
	return 2
end #def
end #class
class B < ActiveRecord::Base
def B.classMethodB
	return 3
end #def
def meth
	return 4
end #def
end #class
class Test_Acquisition <Test::Unit::TestCase
require 'test_helpers.rb'
include Test_Helpers
include Global
def test_helpers
	testAnswer(A,:classMethodA,1)
	obj=A.new
	testAnswer(obj,:methA,2)
	testAnswer(B,:classMethodB,3)
# 	require 'arConnection.rb'
# 	obj=B.new
# 	testAnswer(obj,:meth,4)
end #def test
end #class
###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/no_db.rb'
class Zillow
module ClassMethods
end #ClassMethods
extend ClassMethods
module Constants
end #Constants
include Constants
# attr_reader
def initialize
end #initialize
require_relative '../../test/assertions.rb'
module Assertions
include Minitest::Assertions
module ClassMethods
include Minitest::Assertions
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
All_units_url = 'http://www.zillow.com/b/354-Chestnut-Ave-Long-Beach-CA-90802/33.77148,-118.195976_ll/'
Unit_history_url = 'http://www.zillow.com/homedetails/354-Chestnut-Ave-APT-17-Long-Beach-CA-90802/21240500_zpid/'
end #Examples
end # Zillow

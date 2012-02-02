###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require 'app/models/regexp_tree.rb' # make usable under rake
class BatteryType
include Generic_Table
include NoDB

# Initializes Battery from a hash
def initialize(hash)
	super(hash)
end #initialize
def BatteryType.all
end #all
end #BatteryType
class Battery
include Generic_Table
include NoDB

# Initializes Battery from a hash
def initialize(hash)
	super(hash)
end #initialize
def Battery.all
end #all
end #Battery
class BatteryMeasurement
include Generic_Table
include NoDB

# Initializes BatteryMeasurement from a hash
def initialize(hash)
	super(hash)
end #initialize
def BatteryMeasurement.all
end #all
end #BatteryMeasurement
###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class Minimal3
module Constants
end #Constants
include Constants
module ClassMethods
include Constants
end #ClassMethods
extend ClassMethods
# attr_reader
def initialize
end # initialize
end #Minimal

###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class Minimal
module Constants
end #Constants
include Constants
module ClassMethods
end #ClassMethods
extend ClassMethods
#include DefaultAssertions
#extend DefaultAssertions::ClassMethods
module Examples
include Constants
end #Examples
#include Examples
end #Minimal

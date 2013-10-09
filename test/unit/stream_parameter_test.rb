###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'

class StreamParameterTest < TestCase
def test_foreign_keys_not_nil
	@@model_class.assert_foreign_keys_not_nil
end #
end #StreamParameterTest

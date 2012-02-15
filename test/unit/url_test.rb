###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require 'test/test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class UrlTest < ActiveSupport::TestCase
set_class_variables
def test_find_by_name
 	assert_equal('EEG', Url.find_by_name('EEG').href)
end #find_by_name
def test_parsedURI
end #def
def test_schemelessUrl
 	assert_equal('/home/greg/Desktop/Downloads/emotive/qdot-emokit-2fa5e40/python/logfile.txt', Url.find_by_name('EEG').schemelessUrl)
end #schemelessUrl
def test_uriComponent
end #end
def test_uriArray
end #def
def test_uriHash
end #def
def test_scheme
end #def
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
	define_model_of_test # allow generic tests
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
#	define_association_names #38271 associations
end #def
def test_id_equal
	assert(!@@model_class.sequential_id?, "@@model_class=#{@@model_class}, should not be a sequential_id.")
	assert_test_id_equal
end #test_id_equal
end #Url

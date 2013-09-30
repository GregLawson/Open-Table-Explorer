###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class HostTest < TestCase
set_class_variables
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
#	define_model_of_test # allow generic tests
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement. Sequential id is a class method.")
	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	define_association_names
end #setup
def test_all
	uri=Url.where("href='nmap_local_network'").first
	assert_not_nil(uri)
	file_method=StreamMethod.find_by_name('Shell')
	file_method[:uri]=uri
	file_method.compile_code!
	firing=file_method.fire!
	assert_equal([], firing.errors[:interface_code],"interface_code=#{firing[:interface_code]}")
end #all
def test_general_associations
#more fixtures need to be loaded?	assert_general_associations(@table_name)
end #test
def test_id_equal
	assert(!@@model_class.sequential_id?, "@@model_class=#{@@model_class}, should not be a sequential_id.")
	assert_test_id_equal
end #id_equal
end #Host

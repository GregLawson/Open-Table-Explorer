require 'test/unit'
require 'table.rb'
class TC_MyTest < Test::Unit::TestCase
def setup
	testTable=Table.new('tempTestTable','id')
end

def teardown
	errorMessage=DB.execute('DROP TABLE tempTestTable')
	assert_equal('', errorMessage,"DROP TABLE failed.")
end

def test_fail
	assert(false, 'Assertion was false.')
end
end
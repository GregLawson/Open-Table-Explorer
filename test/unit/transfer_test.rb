require 'test_helper'

class TransferTest < ActiveSupport::TestCase
def setup
	define_association_names
end
def test_general_associations
	assert_general_associations(@table_name)
end
end #class

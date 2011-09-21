require "generic_table"
class Bug < ActiveRecord::Base
has_many :test_runs
include Generic_Table
def logical_primary_key
	return :url
end #def
end # class

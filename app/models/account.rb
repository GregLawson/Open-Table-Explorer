class Account < ActiveRecord::Base
has_many :transfers
def canonicalName(verbose=false)
	return "#{self.inspect}"
end #def
include Generic_Table
scope :ots_line_values, where(:open_tax_solver_line => 'L16a')
def logical_primary_key
	return :name
end #def
end # class

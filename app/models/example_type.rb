# 1a) a regexp should match all examples from itself down the specialization tree.
# 1b) an example should match its regexp and all generalization regexps above if
# 2) an example should not match at least one of its specialization regexps
# 3) example  strings should not equal specialization examples
# 4) specialization regexps have fewer choices (including case) or more restricted repetition
class ExampleType < ActiveRecord::Base
include Generic_Table
require 'test/assertions/ruby_assertions.rb'
belongs_to :generic_type
# find Array of more general types (tree ancestors)
def which_generic_type(association=nil)
	return case association
	when nil
		generic_type
	when :generalize
		generic_type.generalize
	when :specialize
		generic_type.specialize
	else
		raise "Unexpected value for association=#{association.inspect}"
	end #case
end #which_generic_type

end #ExampleType

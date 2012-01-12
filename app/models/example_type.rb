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
def valid_context?
	valid? && valid?(:generalize) && valid?(:specialize)
end #valid_context
def valid?(association=nil)
	gt=which_generic_type(association)
	if gt.nil? then
		return true # edge condition
	elsif gt.is_a?(Array) then #specialize
		if gt.empty? then
			return true # edge condition
		else
			return gt.any? do |g|	# specializations
				data_regexp=g[:data_regexp]
				if !Regexp.new(data_regexp).match(self[:example_string]) then
					true
				else
					$~[0] == self[:example_string] # full string matched
				end #if
			end #all
		end #if
	else
		data_regexp=gt[:data_regexp]
		if Regexp.new(data_regexp).match(self[:example_string]) then
			$~[0] == self[:example_string] # full string matched
		else
			return false
		end #if
	end #if
end #valid
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

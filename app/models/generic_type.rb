class GenericType < ActiveRecord::Base
include Generic_Table
has_many :example_types
has_many :specialize, :class_name => "GenericType",
    :foreign_key => "generalize_id"
belongs_to :generalize, :class_name => "GenericType",
    :foreign_key => "generalize_id"

def generalizations
	if generalize==self then
		return []
	else
		return generalize.generalizations << generalize
	end #if
end #generalizations
def most_general?
	return generalize==self || generalize.nil?
end #most_general
def unspecialized?
	return specialize.empty?
end #unspecialized
# find Array of more specific types (tree children)
def one_level_specializations
	if most_general? then
		return specialize-[self]
	elsif unspecialized? then
		return []
	else
		specialize
	end #if
end #one_level_specializations
def specializations
	if most_general? then
		return (specialize-[self]).map{|s| s.specializations}.flatten + one_level_specializations
	elsif unspecialized? then
		return []
	else
		return specialize.map{|s| s.specializations}.flatten + one_level_specializations
	end #if
end #specializations
def descendants(candidates=GenericType.all)
	candidates.select {|c| c.example_types.all?{|e| !e.valid_parent?(e[:example_string])}}
  
end #descendants
end #GenericType

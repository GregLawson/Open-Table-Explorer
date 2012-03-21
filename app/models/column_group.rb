###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'app/models/global.rb'
module ColumnGroup
module ClassMethods
def defaulted_primary_logical_key?
	 if methods(false).include?('logical_primary_key') then
	 	return nil
	 else
	 	return true
	 end #if
end #defaulted_primary_logical_key
def default_logical_primary_key
	if logical_attributes.include?(:name) then
		return [:name]
	else
		candidate_logical_primary_key=logical_attributes
		if !candidate_logical_primary_key.empty? then
			return candidate_logical_primary_key
		else
			model_history_type=history_type?
			if model_history_type==[] then
				raise "Can't find a default primary logical key in #{self.inspect}."
			else
				return model_history_type[0..0] # first prioritized column
			end #if
			return [:id]
		end #if
		return logical_attributes
	end #if
end #default_logical_primary_key
# Override if default is wrong.
def logical_primary_key
	return default_logical_primary_key
end #logical_primary_key
def attribute_ddl(attribute_name)
	table_sql= self.to_sql
	attribute_sql=table_sql.grep(attribute_name)
	return attribute_sql
end #attribute_ddl

def attribute_ruby_type(attribute_name)
	return first[attribute_name].class
end #attribute_ruby_type
def attribute_rails_type(attribute_name)
	return first[attribute_name].class
end #attribute_rails_type
def candidate_logical_keys_from_indexes
	indexes=self.connection.indexes(self.name.tableize)
		if indexes != [] then
			indexes.map do |i|
				i.columns
			end #map
		else
			return nil
		end #if
end #candidate_logical_keys_from_indexes
# Is attribute an numerical (analog) (versus categorical (digital) value)
# default logical primary keys ignore analog values
# Statistical procedures will treat these attributes as continuous
# override for specific classes
# by default the following are considered analog:
#  Float
#  Time
#  DateTime
#  id for sequential_id?
def numerical?(attribute_name)
	if ['created_at','updated_at'].include?(attribute_name.to_s) then
		return true
	elsif [Float, Bignum, DateTime, Time].include?(attribute_ruby_type(attribute_name)) then
		return true
	elsif categorical?(attribute_name) then
		return false
	else
		return false
	end #if
end #numerical
def probably_numerical?(attribute_name)
	if [Date].include?(attribute_ruby_type(attribute_name)) then
		return true
	else
		return false
	end #if
end #probably_numerical
def categorical?(attribute_name)
	if [Symbol].include?(attribute_ruby_type(attribute_name)) then
		return true
	elsif foreign_key_names.include?(attribute_name.to_s) then
		parent=association_class(foreign_key_to_association_name(attribute_name))
		return !parent.sequential_id?
	elsif defaulted_primary_logical_key? then
		if attribute_name.to_sym==:id then
			return logical_attributes==[]
		else
			return false
		end #if
	else #overridden logical primary key
		if attribute_name.to_sym==:id then
			return !sequential_id?
		else
			return logical_primary_key.include?(attribute_name)
		end #if
	end #if
end #categorical
def probably_categorical?(attribute_name)
	if [String, NilClass].include?(attribute_ruby_type(attribute_name)) then
		return true
	elsif attribute_name.to_sym==:id then
		if defaulted_primary_logical_key? then
			return logical_attributes==[]
		else #overridden logical primary key
			return logical_primary_key.include?(:id)
		end #if
	else
		return false
	end #if
end #probably_categorical
def column_symbols
	return column_names.map {|name| name.to_sym}
end #column_symbols
def logical_attributes
	return (column_symbols-History_columns).select {|name| !numerical?(name)} # avoid :id recursion
end #logical_attributes
def is_logical_primary_key?(attribute_names)
	quoted_primary_key
	if self.respond_to?(:logical_primary_key) then
		if Set[logical_primary_key]==Set[attribute_names] then
			return true
		end #if
	end #if
	attribute_names.each do |attribute_name|
		if attribute_name='id' then
			return false
		elsif !column_names.include(attribute_name.to_s) then
			return false
		end #IF	
	end #each
	if self.count==self.count(:distinct => true, :select => attribute_names) then
		return true
	else
		return false
	end #if
	return true # if we get here
end #logical_primary_key
History_columns=[:updated_at, :created_at, :id]
def history_type?
	history_type=[] # nothing yet
	History_columns.each do |history_column|
		history_type << history_column if column_symbols.include?(history_column) 
	end #each
	return history_type
end #history_type
def sequential_id?
	history_types_not_in_logical_key= history_type?-logical_primary_key
	return history_types_not_in_logical_key!=history_type?

end # sequential_id
def logical_primary_key_recursive
	if sequential_id? then
		return logical_primary_key
	else
		foreign_keys=logical_primary_key.map do |e| 
			if is_foreign_key_name?(e) then
				association_name=foreign_key_to_association_name(e)
				association=self.first.foreign_key_to_association(association_name)
				if association.nil? then
					nil
				else
					association.class.logical_primary_key_recursive
				end #if
			else
				e.to_sym
			end #if
		end #map
		{self.name => foreign_keys}
	end #if
end #logical_primary_key_recursive
end #ClassMethods
end #ColumnGroup

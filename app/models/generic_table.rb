
###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'app/models/global.rb'
#require 'lib/tasks/testing_file_patterns.rb'
module NoDB # provide duck-typed ActiveRecord like functions.
attr_reader :attributes
include ActiveModel
def initialize(hash=nil)


	if hash.nil? then
		@attributes=ActiveSupport::HashWithIndifferentAccess.new
	else
		@attributes=ActiveSupport::HashWithIndifferentAccess.new(hash)
	end #if
end #NoDB
def [](attribute_name)
	@attributes[attribute_name]
end #[]
def []=(attribute_name, value)
	@attributes[attribute_name]=value
end #[]
def has_key?(key_name)
	return @attributes.has_key?(key_name)
end #has_key?
def keys
	return @attributes.keys
end #keys
end #
module ActiveRecord
class Base
def self.column_order
	ret=logical_primary_key
	ret+=column_symbols-logical_primary_key-[:id]
	return ret
end #column_order
def column_html(column_symbol)
	return self[column_symbol].inspect
end #column_html
def row_html(column_order=nil)
	if column_order.nil? then
		column_order=self.class.column_order
	end #if
	ret="<tr>"
	column_order.each do |col|
		ret+='<td>'+column_html(col).inspect+'</td>'
	end #each
	ret+="</tr>"
	return ret

end #row_html
def Base.header_html(column_order=nil)
	if column_order.nil? then
		column_order=self.column_order
	end #if
	ret="<tr>"
	column_order.each do |header|
		ret+='<th>'+header.to_s+'</th>'
	end #each
	ret+="</tr>"
	return ret
end #header_html
# Produce default HTML for ActiveRecord model
def Base.table_html(column_order=nil)
	if column_order.nil? then
		column_order=self.column_order
	end #if
	ret="<table>"
	ret+=header_html(column_order)
	self.all.each do |row|
		ret+=row.row_html(column_order)
	end #each
	ret+="</table>"
	return ret
end #table_html
# apply block to an association
def Base.association_refs(class_reference=@@example_class_reference, association_reference=@@example_association_reference, &block)
	if class_reference.kind_of?(Class) then
		klass=class_reference
	else
		klass=class_reference.class
	end #if
	association_reference=association_reference.to_sym
	assert_instance_of(Symbol,association_reference,"In association_refs, association_reference=#{association_reference} must be a Symbol.")
	assert_instance_of(Class,class_reference,"In test_is_association, class_reference=#{class_reference} must be a Class.")
#	assert_kind_of(ActiveRecord::Base,class_reference)
	assert_ActiveRecord_table(class_reference.name)
	block.call(class_reference, association_reference)
end #association_refs
# transform association name into association records for instance
def name_to_association(association_name)
	method(association_name).call
end #name_to_association
# List names (as Strings) of all foreign keys.
def Base.foreign_key_names
	content_column_names=content_columns.collect {|m| m.name}
	special_columns=column_names-content_column_names
	possible_foreign_keys=special_columns.select { |m| m =~ /_id$/ }
	return possible_foreign_keys
end #foreign_key_names
def Base.is_foreign_key_name?(symbol)
	return foreign_key_names.include?(symbol.to_s) && is_association?(Base.foreign_key_to_association_name(symbol))
end #foreign_key_name
# translate foreign_key into asociation name
# Example: foreign_Key_to_association_name(:fk_id)=='fk' association
def Base.foreign_key_to_association_name(foreign_key)
	foreign_key.to_s.sub(/_id$/,'')
end #foreign_key_to_association_name
# translate foreign_key into asociation
# Example: foreign_Key_to_association(:fk_id)==fk association
def foreign_key_to_association(foreign_key)
	name_to_association(Base.foreign_key_to_association_name(foreign_key))
end #foreign_Key_to_association
# list names of the associations having foreign keys.
def Base.foreign_key_association_names
	foreign_key_names.map {|fk| fk.sub(/_id$/,'')}
end #foreign_key_association_names
def Base.associated_foreign_key_name(association_referenced_by_foreign_key)
	if !is_association?(association_referenced_by_foreign_key.to_s.singularize) then
		raise "Association #{association_referenced_by_foreign_key.to_s.singularize} is not an association of #{self.name}."
	end #if
	many_to_one_foreign_keys=foreign_key_names
	matchingAssNames=many_to_one_foreign_keys.select do |fk|
		ass=fk[0..-4].to_sym
		ass==association_referenced_by_foreign_key.to_s.singularize.to_sym
	end #end
	if matchingAssNames.size==0 then
		raise "Association #{association_referenced_by_foreign_key} does not have a corresponding foreign key in association #{self.name}."
	end #if
	return matchingAssNames.first
end #associated_foreign_key_name
def foreign_key_value(association_name)
	return self[association_name.to_s+'_id']
end #foreign_key_value
# find records pointed to by foreign key.
def associated_foreign_key_records(association_with_foreign_key)
	class_with_foreign_key=self.class.association_class(association_with_foreign_key)
	foreign_key_symbol=class_with_foreign_key.associated_foreign_key_name(self.class.name.tableize)
	associated_records=class_with_foreign_key.where(foreign_key_symbol => self[:id])

	return associated_records
end #associated_foreign_key_records
# Does association have me as one of its associations?
def Base.is_matching_association?(association_name)
	 if is_association?(association_name) then
		association_class=association_class(association_name)
		 if association_class.nil? then
			 raise "Association #{association_name.classify} is not a defined constant."
		end #if
		table_symbol=association_class.association_method_symbol(self)
		 if association_class.is_association?(table_symbol) then
			 return true
		elsif association_class.is_association?(association_method_symbol(self.table_name.singularize.to_sym))  then
			return true
		else
			 return false
		end #if
	else
		return false
	end #if
end #is_matching_association
# return automagically created methods for an association.
def Base.association_methods(association_name)
	return matching_instance_methods(association_name,false)
end #association_methods
def Base.association_patterns(association_name)
	patterns=association_methods(association_name).map do |n| 
		matchData=Regexp.new(association_name.to_s).match(n)
		Regexp.new('^'+matchData.pre_match+'([a-z0-9_]+)'+matchData.post_match+'$')
	end #map
	return Set.new(patterns)
end #association_patterns
def Base.match_association_patterns?(association_name,association_pattern)
	patterns=association_methods(association_name).map do |n| 
		matchData=association_pattern.match(association_pattern)
	end #map
	
	instance_respond_to?(association_name)
end #match_association_patterns
def Base.is_association_patterns?(association_name,association_patterns)
	(association_patterns(association_name)-association_patterns.to_a).empty?&&
	(association_patterns-association_patterns(association_name).to_a).empty?
end #is_association_patterns
def Base.is_association?(association_name)
	# Don’t create associations that have the same name as instance methods of ActiveRecord::Base.
	if ActiveRecord::Base.instance_methods_from_class.include?(association_name.to_s) then
		raise "# Don’t create associations that have the same name (#{association_name.to_s})as instance methods of ActiveRecord::Base (#{ActiveRecord.instance_methods_from_class})."
	end #if
	if association_name.to_s[-4,4]=='_ids' then # automatically generated
		return false
	elsif self.instance_respond_to?(association_name) and self.instance_respond_to?((association_name.to_s+'=').to_sym)  then
		return true
	else
		return false
	end
end #is_association
def Base.is_association_to_one?(association_name)
	if is_association?(association_name)  and !self.instance_respond_to?((association_name.to_s.singularize+'_ids').to_sym) and !self.instance_respond_to?((association_name.to_s.singularize+'_ids=').to_sym) then
		return true
	else
		return false
	end
end #association_to_one
def Base.is_association_to_many?(association_name)
	if is_association?(association_name)  and self.instance_respond_to?((association_name.to_s.singularize+'_ids').to_sym) and self.instance_respond_to?((association_name.to_s.singularize+'_ids=').to_sym) then
		return true
	else
		return false
	end
end #is_association_to_many
@@Example_polymorphic_patterns=Set.new([/^([a-z0-9_]+)$/, /^set_([a-z0-9_]+)_target$/, /^([a-z0-9_]+)=$/, /^autosave_associated_records_for_([a-z0-9_]+)$/, /^loaded_([a-z0-9_]+)?$/])

def Base.is_polymorphic_association?(association_name)
	return is_association_patterns?(association_name,@@Example_polymorphic_patterns)
end #is_polymorphic_association
def Base.association_names_to_one
	return instance_methods(false).select {|m| is_association_to_one?(m)}
end #association_names_to_one
def Base.association_names_to_many
	return instance_methods(false).select {|m| is_association_to_many?(m)}
end #association_names_to_many
def Base.association_names
	return instance_methods(false).select {|m| is_association_to_one?(m) or is_association_to_many?(m)}
end #association_names
def Base.model_file_name
	return "app/models/#{name.tableize.singularize}.rb"
end #model_file_name
def Base.grep_command(content_regexp_string, filename_regexp_string='-r {app/models/,test/unit/}*.rb', redirection='')
	if redirection.empty? then
		return "grep \"#{content_regexp_string}\" #{filename_regexp_string}"
	else
		return "grep \"#{content_regexp_string}\" #{filename_regexp_string} #{redirection}"
	end #if
end #grep_command
def Base.model_grep_command(model_regexp_string)
	if !Generic_Table.rails_MVC_class?(self.name) then
		raise "#{self.name}.model_grep only works on Rails MVC."
	end #if
	return "grep \"#{model_regexp_string}\" #{model_file_name} &>/dev/null"
end #model_grep_command
def Base.model_grep(model_regexp_string)
	return `#{model_grep_command(model_regexp_string)}`
end #model_grep
def Base.association_grep_pattern(model_regexp_string,association_name)
	return "#{model_regexp_string}:#{association_name}" # no end of line $, so that polymorphic associations are found.
end #association_grep_command
ASSOCIATION_MACRO_LETTERS='[has_manyoneblgtd]'
ASSOCIATION_MACRO_PATTERN="^[hb]#{ASSOCIATION_MACRO_LETTERS}*\s\s*"
def Base.grep_all_associations_command
	return grep_command(ASSOCIATION_MACRO_PATTERN, 'app/models/*.rb')
end #grep_all_associations_command
def Base.all_associations
	regexp='([a-z_.]*):('+ASSOCIATION_MACRO_PATTERN[1..-1]+')(.*)'
	return `#{grep_all_associations_command}`.split("\n").map do |l| 
		Regexp.new(regexp).match(l)[1..-1]
		end #map
end #all_associations
def Base.association_macro_type(association_name)
	hits=association_grep(ASSOCIATION_MACRO_PATTERN, association_name)
	if hits.empty? then
		return nil
	else
		return hits.match("(#{ASSOCIATION_MACRO_PATTERN})")[1].sub(/\s*$/, '').to_sym
	end #if
end #association_macro_type
def Base.association_grep(model_regexp_string,association_name)
	return model_grep(association_grep_pattern(model_regexp_string,association_name))
end #association_grep
def Base.has_many_association?(association_name)
	return association_grep('has_many',association_name)
end #has_many_association
# expects a singular association name
def Base.belongs_to_association?(association_name)
	return association_grep('^belongs_to ',association_name)!=''
end #belongs_to_association
def Base.has_one_association?(association_name)
	return association_grep('^has_one',association_name)
end #has_one_association
# Returns model name in a canonical form from Class or string, ...
# The return value is canonical in that multiple possible inputs produce the same output.
# always returns a plural, whereas a macro may have a singular argument.
# Generally returns association_table_name.class.name.tableize.to_sym for any object.
# tableize handles some pluralizing, but symbols are unchanged
#routine is meant to handle usual cases in Rails method naming not pathological cases.
# Does not assume an association.
# This flexibility should not be overused. 
# It is intended for finding inverse associations and allowing assertion error messages to suggest what you might have intended.
def Base.name_symbol(model_name)
	if model_name.kind_of?(Class) then
		return model_name.name.tableize.to_sym					
	elsif model_name.kind_of?(String) then
		return model_name.tableize.to_sym						
	elsif model_name.kind_of?(Symbol) then
		return model_name.to_sym
	else # other object
		return model_name.class.name.tableize.to_sym
	end #if
end #name_symbol
# checks whether association symbol exists or if a singular or plural name exists.
def Base.association_method_plurality(association_table_name)
	if self.instance_respond_to?(association_table_name) then
		return association_table_name.to_sym
	elsif self.instance_respond_to?(association_table_name.to_s.singularize) then
		return association_table_name.to_s.singularize.to_sym
	elsif self.instance_respond_to?(association_table_name.to_s.pluralize) then
		return association_table_name.to_s.pluralize.to_sym
	else # don't know what to do; most likely cure
		return association_table_name.to_s.pluralize.to_sym
	end #if
end #association_method_plurality
# For convenience handles both type and plurality.
def Base.association_method_symbol(association_table_name)
	return association_method_plurality(name_symbol(association_table_name))
end #association_method_symbol
# return association's default_class name
# can be used as a boolean test
def Base.association_default_class_name?(association_name)
	default_association_class_name=association_name.to_s.classify
	if eval("defined? #{default_association_class_name}") then
		return default_association_class_name
	else
		return nil # not default class name
	end #if
end #association_default_class_name
# return class when passed a symbol reference
def Base.association_class(association_name)
	 if !is_association?(association_method_symbol(association_name)) then
		raise "#{association_method_symbol(association_name)} is not an association of #{self.name}."
	elsif is_polymorphic_association?(association_name) then
		raise "Polymorphic associations #{association_method_symbol(association_name)} of #{self.name} do not have a single class.. Need instance not class method "
	else
		default_class_defined=association_default_class_name?(association_name)
		if default_class_defined then
			return Generic_Table.class_of_name(association_default_class_name?(association_name))
		else
			all_parents=all
			all_association_classes=all_parents.map do |bc|
				bc.association_class(association_name)
			end.flatten.uniq #map
			if all_association_classes.size==1 then
				return all_association_classes[0] # remove Array
			else
				return all_association_classes # polymorphic? impossible?
			end #if
		end #if
	end #if
end #Base_association_class
def association_class(association_name)
	 if !self.kind_of?(ActiveRecord::Base) then
		raise "#{self.class.name} is not an ActiveRecord::Base."
	 elsif !self.class.is_association?(self.class.association_method_symbol(association_name)) then
		raise "#{self.class.association_method_symbol(association_name)} is not an association of #{self.name}."
	else
		association=name_to_association(association_name)
		if association.instance_of?(Array) then
			classes=association.enumerate(:map){|r| r.class}.uniq
			if classes.size==1 then
				return classes[0] # remove Array
			else
				return classes # polymorphic? impossible?
			end #if
		else
			return association.enumerate(:map){|r| r.class}
		end #if
	end #if
end #association_class
def foreign_key_points_to_me?(ar_from_fixture,association_name)
	associated_records=testCallResult(ar_from_fixture,association_name)
	if associated_records.instance_of?(Array) then
		associated_records.each do |ar|
			fkAssName=ar_from_fixture.class.name.tableize.singularize
			fk=ar.class.associated_foreign_key_name(fkAssName.to_s.to_sym)
			@associated_foreign_key_id=ar[fk]
		end #each
	else # single record
			ar.class.associated_foreign_key_name(associated_records,association_name).each do |fk|
				assert_equal(ar_from_fixture.id,associated_foreign_key_id(associated_records,fk.to_sym),"assert_foreign_key_points_to_me: associated_records=#{associated_records.inspect},ar_from_fixture=#{ar_from_fixture.inspect},association_name=#{association_name}")
			end #each
	end #if
end #foreign_key_points_to_me
# returns :to_one, :to_many, or :not_an_association
def Base.association_arity(association_name)
	if is_association_to_one?(association_name) then
		return :to_one
	elsif is_association_to_many?(association_name) then
		return :to_many
	else 
		return :not_an_association
	end #if
end #association_arity
# concatenate association_arity and association_macro_type
def Base.association_type(association_name)
	return (association_arity(association_name).to_s+'_'+association_macro_type(association_name).to_s).to_sym
end #association_type
def Base.is_active_record_method?(method_name)
	if ActiveRecord::Base.instance_methods_from_class(true).include?(method_name.to_s) then
		return true
	else
		return false
	end #if
end #is_active_record_method
# Whether primay logical key has been overridden 
# or ActiveRecord::Base.logical_primary_key is used.
# nil returned if overridden.
# true returned otherwise.
def Base.defaulted_primary_logical_key?
	 if methods(false).include?('logical_primary_key') then
	 	return nil
	 else
	 	return true
	 end #if
end #defaulted_primary_logical_key
def Base.default_logical_primary_key
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
def Base.logical_primary_key
	return default_logical_primary_key
end #logical_primary_key
def Base.attribute_ddl(attribute_name)
	table_sql= self.to_sql
	attribute_sql=table_sql.grep(attribute_name)
	return attribute_sql
end #attribute_ddl

def Base.attribute_ruby_type(attribute_name)
	return first[attribute_name].class
end #attribute_ruby_type
def Base.attribute_rails_type(attribute_name)
	return first[attribute_name].class
end #attribute_rails_type
def Base.candidate_logical_keys_from_indexes
	indexes=self.connection.indexes(self.name.tableize)
		if indexes != [] then
			indexes.map do |i|
				i.columns
			end #map
		else
			return nil
		end #if
end #candidate_logical_keys_from_indexes
# Is attribute an analog (versus digital value)
# default logical primary keys ignore analog values
# Statistical procedures will treat these attributes as continuous
# override for specific classes
# by default the following are considered analog:
#  Float
#  Time
#  DateTime
#  id for sequential_id?
def Base.analog?(attribute_name)
	if [Float, Bignum, DateTime, Time].include?(attribute_ruby_type(attribute_name)) then
		return true
	elsif [String, Symbol].include?(attribute_ruby_type(attribute_name)) then
		return false
	elsif ['created_at','updated_at'].include?(attribute_name.to_s) then
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
end #analog
def Base.column_symbols
	return column_names.map {|name| name.to_sym}
end #column_symbols
def Base.logical_attributes
	return (column_symbols-History_columns).select {|name| !analog?(name)} # avoid :id recursion
end #logical_attributes
def Base.is_logical_primary_key?(attribute_names)
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
# from http://en.wikipedia.org/wiki/Algorithms_for_calculating_variance
# Skewness is defined at http://en.wikipedia.org/wiki/Skewness
# kurtosis is defined at http://en.wikipedia.org/wiki/Kurtosis
def Base.one_pass_statistics(column_name)
    n = 0
    mean = 0
    m2 = 0
    m3 = 0
    m4 = 0
    min=nil; max=nil
	max_key, min_key = nil # declare scope outside loop!
    has_id=column_names.include?('id')
    all.each do |row|
        x=row[column_name]
        n1 = n
        n = n + 1
        delta = x - mean
        delta_n = delta / n
        delta_n2 = delta_n * delta_n
        term1 = delta * delta_n * n1
        mean = mean + delta_n
        if n==1 then
	    min=x # value for nil
	    max=x # value for nil
	    if has_id then
		    min_key=row.id
		    max_key=row.id
	    else
		    min_key=row.logical_primary_key_value_recursive
		    max_key=row.logical_primary_key_value_recursive
	    end #if
	else
            m4 = m4 + term1 * delta_n2 * (n*n - 3*n + 3) + 6 * delta_n2 * m2 - 4 * delta_n * m3
            m3 = m3 + term1 * delta_n * (n - 2) - 3 * delta_n * m2
            m2 = m2 + delta*(x - mean)
	    if x<min then
	    	min=x
		if has_id then
		    min_key=row.id
	    	else
		    min_key=row.logical_primary_key_value_recursive
	    	end #if
	    end #if  # value for not nil
	    if x>max then
	    	max=x
		if has_id then
			max_key=row.id
		else
			max_key=row.logical_primary_key_value_recursive
		end #if
	    end #if  # value for not nil
	end #if
    end #each
    return nil if n==0
    {
    :n => n,
    :variance_n => m2/n,
    :variance => m2/(n - 1), 
    :skewness=> Math::sqrt(n)*m3/(m2**(3/2)),
    :kurtosis => (n*m4) / (m2*m2) - 3,
    :min => min,
    :min_key => min_key,
    :mean => mean,
    :max => max,
    :max_key => max_key,
    :has_id => has_id
    }
end #one_pass_statistics
History_columns=[:updated_at, :created_at, :id]
def Base.history_type?
	history_type=[] # nothing yet
	History_columns.each do |history_column|
		history_type << history_column if column_symbols.include?(history_column) 
	end #each
	return history_type
end #history_type
def Base.sequential_id?
	history_types_not_in_logical_key= history_type?-logical_primary_key
	return history_types_not_in_logical_key!=history_type?

end # sequential_id
def self.logical_primary_key_recursive
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
# logical key with each foeign key replaced by logical key value pointed to
def logical_primary_key_recursive_value(delimiter=',')
	if self.class.sequential_id? then
		return logical_primary_key_value
	else
		self.class.logical_primary_key.map do |e| 
			if self.class.is_foreign_key_name?(e) then
				association=foreign_key_to_association(e)
				if association.nil? then
					nil
				else
					association.logical_primary_key_recursive_value 
				end #if
			else
				self[e]
			end #if
		end #map
	end #if
end #logical_primary_key_recursive_value
def logical_primary_key_value(delimiter=',')
	if self.class.sequential_id? then
		if self.respond_to?(:logical_primary_key) then # still sequential, not requred, default
			return self[:created_at] # better sequential key
		else
			return id # logical primary key
		end
	else
		if self.class.logical_primary_key.is_a?(Array) then
			return self.class.logical_primary_key.map {|k| self[k]}.join(delimiter)
		else #not array
			return self[self.class.logical_primary_key]
		end #if
	end #if
end #logical_primary_key_value


end #class Base
end #module ActiveRecord
class String
def single_grep(context, pattern)
	regexp=Regexp.new(pattern)
	matchData=regexp.match(self)
	if matchData then
		ActiveSupport::HashWithIndifferentAccess.new(:context => context, :matchData => matchData)
	else
		nil #don't select line for return
	end #if
end #single_grep
end #String
module Enumerable
def nested_grep(context, pattern)
	map do |e|
		e.single_grep(context, pattern)
	end.compact #map
end #nested_grep
def files_grep(pattern, delimiter="\n")
	map do |p|
		IO.read(p).split(delimiter).map do |l|
			l.single_grep(p, pattern)
		end.compact #grep
	end.flatten #map
end #files_grep
end #Enumerable
module Generic_Table
require 'app/models/IncludeModuleClassMethods.rb'
def Generic_Table.grep(file_regexp, pattern, delimiter="\n")
	regexp=Regexp.new(pattern)
	RegexpTree.new(file_regexp).pathnames.map do |p|
		IO.read(p).split(delimiter).map do |l|
			matchData=regexp.match(l)
			if matchData then
				{:pathname => p, :match => matchData[1]}
			else
				nil #don't select line for return
			end #if
		end.compact #grep
	end.flatten #map
end #grep
def Generic_Table.class_of_name(name)
	 return name.to_s.constantize
rescue
	return nil
end #class_of_name
def Generic_Table.is_generic_table?(model_class_name)
	return false if (model_class_name =~ /_ids$/)
	if Generic_Table.is_ActiveRecord_table?(model_class_name) then
		model_class=Generic_Table.eval_constant(model_class_name.classify)
		model_class.module_included?(Generic_Table)
	else
		return false
	end #if
end #def
def Generic_Table.table_exists?(table_name)
	TableSpec.connection.table_exists?(table_name)
end #table_exists
def Generic_Table.rails_MVC_class?(table_name)
	return CodeBase.rails_MVC_classes.map{|c| c.name}.include?(table_name.to_s.classify)
end #rails_MVC_class
def Generic_Table.is_generic_table_name?(model_file_basename,directory='app/models/',extention='.rb')
	if File.exists?(directory+model_file_basename+extention) then
		return true
	else
#		puts "File.exists?(\"#{directory+model_file_basename+extention})\")=#{File.exists?(directory+model_file_basename+extention)}"
		return false
	end #if
end #is_generic_table_name


def Generic_Table.activeRecordTableNotCreatedYet?(obj)
	return (obj.class.inspect=~/^[a-zA-Z0-9_]+\(Table doesn\'t exist\)/)==0
end #activeRecordTableNotCreatedYet
def updates(variableHashes)
#	Global::log.info("variableHashes.inspect=#{variableHashes.inspect}")
	variableHash={} # merge into single hash
	variableHashes.each do |vhs|
		vhs.each do |vh|
			variableHash.merge(vh)
		end #each
	end #each
#	Global::log.info("variableHash.inspect=#{variableHash.inspect}")
	if exists?(variableHash) then
		@@log.debug("record already exists")
	else
		row=self.new
#		Global::log.info( "variableHash['khhr_observation_time_rfc822']=#{variableHash['khhr_observation_time_rfc822']}")
		reportNull(variableHash)
		row.update_attributes(variableHash)
		now=Time.new
		if row.has_attribute?('created_at') then
			row.update_attribute("created_at",now)
		end #if
		if row.has_attribute?('updated_at') then
			row.update_attribute("updated_at",now)
		end #if
		#update_attribute("id","NULL") 
	end # if else
	
end #def

def process(acquisitionData)
	acqClasses=Generic_Acquisitions.parse_classes(m)
	acqClasses.each map do |ac|
		variableHashes=ac.parse(acquisitionData)
	end #each
	row.updates(variableHashes)
	row.save
	return row
end
def log
begin
	sample
	wait
end until false
end # method log
def monitor(keys) # update continously
#	Global::log.info("in monitor self.name=#{self.name}")
	whoAmI
	#generic_acquisitions
	begin
		acquisitionData=acquire
		if self.acquisitionsUpdated?(acquisitionData) then
			row=find_or_initialize(keys)
			row.process(acquisitionData)
			row.printLog
		else
#			Global::log.info(acquisitionData)
		end
	
		wait
	end until false
end # method monitor
def sample
	@acqClasses=Generic_Acquisitions.parse_classes(m)
	@acqClasses.map do |ac|
		@acquisitionData=acquire
	end #map
	@acquisitionData.each do |ad|
		if acquisitionUpdated?(ad) then
			row=self.create
			row=process(ad)
			row.printLog
		else
			puts ad
		end
	end
end
def updateMaxTypeNum(maxTypeNums)
	adaptiveAcquisition
	values= getValues
	values.each_index do |i|
		maxTypeNums[i]=[Import_Column.firstMatch(values[i]),maxTypeNums.fetch(i,-1)].max
	end
	return   maxTypeNums
end #def
def column_Definitions
	adaptiveAcquisition
	names=getNames
#	Global::log.debug("names=#{names}")
	typeNums=[] # make it array, so array functons can be used
        numSamples=0
        begin
        	typeNums=updateMaxTypeNum(typeNums)
        	numSamples = numSamples+1
        end until streamEnd or numSamples>10
	@sqlTypes=[]
	ret=[]
	names.each_index do |i| 
		@sqlTypes.push(Import_Column.row2ImportType(typeNums[i]))
#		Global::log.info("#{names[i]} #{@sqlTypes[i]} \"#{@sqlValues[i]}\" #{typeNums[i]}")
		ret.push([names[i],@sqlTypes[i]])
#		Global::log.info("ret=#{ret}")
	end
#	Global::log.info("ret=#{ret}")
	return ret
end
def adaptiveAcquisition
	notModifieds=0
	done=false
	begin
		@acquisitionData=acquire 
		if acquisitionsUpdated? then
			done=true
		else
			notModifieds=notModifieds+1
			if notModifieds.modulo(10)==0 then
#				Global::log.info("notModifieds=#{notModifieds}")
#				Global::log.info("@acquisitionData=#{@acquisitionData}")
			else
#				Global::log.info("not updated")	
			end
		end	
		#sleep self[:interval]
		wait
	end until done
#	Global::log.info("notModifieds=#{notModifieds}")
	return @acquisitionData
end 

def find_or_initialize(findCriteria)
	records=find(:all,findCriteria)
	if records.empty? then
		ret= self.new(findCriteria)
		return ret
	elsif records.size==1 then
		return records[0]
	else
		@@log.debug("criteria not unque; records=#{records.inspect}")
		raise 
	end
end
def display(exp)
 puts "#{exp}="
 puts "#{eval(exp)}"
 puts "#{exp}=#{eval(exp)}"
end
def Require_Table(tableName=self.to_s)
#	Global::log.info("in Require_Table self.class=#{self.class}")
#	Global::log.info("in Require_Table self.to_s=#{self.to_s}")
#	Global::log.info("in Require_Table tableName=#{tableName}")
	if pg_table_exists? then
		#return new
	else
		puts "Table #{tableName} does not exist. Enter following command in rails to create:"
		#puts Generic_Columns.scaffold(Generic_Columns.column_Definitions)
		puts scaffold(self.column_Definitions)
#		puts scaffold(self.column_Definitions)
	end
end
def scaffold (columnDefs)
#	Global::log.info("singularTableName=#{singularTableName}")
#	Global::log.info("in scaffold singularTableName=#{singularTableName}")
	rails="script/generate scaffold #{singularTableName} "
	columnDefs.each do  |col|
		rails="#{rails} #{col[0]}:#{col[1]}"
		#puts rails
	end
	return rails
end
def singularTableName
#	Global::log.info("in singularTableName self.class=#{self.class}")
#	Global::log.info("in singularTableName self.to_s=#{self.to_s}")
	return self.to_s.chop
end
def addColumn(name,type)
	sql="ALTER TABLE  #{@table_name} ADD COLUMN #{name.downcase} #{type};"
	errorMessage=DB.execute(sql)
	return errorMessage
end
def requireColumn(name,type)
#	Global::log.info("self.class=#{self.class}")
#	Global::log.info("name=#{name}")
	if has_attribute?(name) then
		return ""
	else
		puts "Column #{name} to be created with #{type}" if $VERBOSE
		return addColumn(name,type)
	end
end
def pg_table_exists?(tableName=self.to_s.downcase)
	sql="select table_name from information_schema.tables where table_schema='public' AND table_name='#{tableName}';"
#	Global::log.debug("sql=#{sql}")
	res  = find_by_sql(sql)
#	Global::log.info("res.size=#{res.size}")
	#puts "res=#{res}"
	return res.size>0
end
def addPrefix(variableHash,prefix)
	ret=Hash.new
	variableHash.each_pair do |key,value|
		ret["#{prefix}#{key}"]=value
	end
	return ret
end
def exclude(variableHash,exclusionList=[])
	ret=Hash.new
	variableHash.each_pair do |key,value|
		if !exclusionList.include?(key)
			ret[key]=value
		end
	end
end
def initFail
	puts "Table does not exist. Enter following command in rails to create:"
	puts self.class.scaffold
	exit
end
def Generic_Table.rubyClassName(model_class_name)
	model_class_name=model_class_name[0,1].upcase+model_class_name[1,model_class_name.length-1] # ruby class names are constants and must start with a capital letter.
	# remainng case is unchanged to allow camel casing to separate words for model names.
	return model_class_name
end #def
def Generic_Table.classDefiniton(model_class_name)
	return "class #{Generic_Table.rubyClassName(model_class_name)}  < ActiveRecord::Base\ninclude Generic_Table\nend"
end #def
def Generic_Table.classReference(model_class_name)
	rubyClassName=Generic_Table.rubyClassName(model_class_name)
	model_class_eval=eval("#{classDefiniton(rubyClassName)}\n#{rubyClassName}")
	return model_class_eval
end #def
def table2yaml(table_name=self.class.name.tableize)
	i = 0 #"000"
	limit=100 # too long slow all tests, too short give poor test coverage
	sql  = "SELECT * FROM %s LIMIT #{limit}"
    	File.open("test/fixtures/#{table_name}.yml.gen", 'w') do |file|
      		data = self.class.limit(limit).all
#		puts "data.inspect=#{data.inspect}"
		file.write "# Read about fixtures at http://ar.rubyonrails.org/classes/Fixtures.html"
		 file.write data.inject({}) { |hash, model_instance|
			i=i+1
			fixture_attributes=model_instance.attributes
			fixture_attributes.delete('created_at')  # automatically regenerated
			fixture_attributes.delete('updated_at')  # automatically regenerated
			if sequential_id? then
				primaryKeyValue=i
				fixture_attributes['id']=i  # automatically regenerated
			else
				primaryKeyValue=model_instance.logical_primary_key_value
				fixture_attributes.delete('id')  # automatically regenerated
			end
#			puts "fixture_attributes.inspect=#{fixture_attributes.inspect}"
#			puts "fixture_attributes.to_yaml.inspect=#{fixture_attributes.to_yaml.inspect}"
			hash[primaryKeyValue] = fixture_attributes
			hash
		}.to_yaml
	end# file open
end #def
def self.db2yaml
	skip_tables = ["schema_info","tedprimaries","weathers"]
  (	ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
		table2yaml(table_name)
	end #each
end #def
# Display attribute or method value from association even if association is nil
def association_state(association_name)
	case self.class.association_arity(association_name)
	when :to_one
		foreign_key_value=foreign_key_value(association_name)
		if foreign_key_value.nil? then # foreign key uninitialized
			return "Foreign key #{association_name.to_s}_id defined as attribute but has nil value."
		#~ elsif foreign_key_value.empty? then # foreign key uninitialized
			#~ return "Foreign key #{association_name.to_s}_id defined as attribute but has empty value."
		else
			ass=send(association_name)
			if ass.nil? then
				return "Foreign key #{association_name.to_s}_id has value #{foreign_key_value.inspect} but the association returns nil."
			else
				return "Foreign key #{association_name.to_s}_id has value #{foreign_key_value.inspect},#{ass.inspect} and returns type #{ass.class.name}."
			end
		end
	when :to_many
		ass=send(association_name)
		associations_foreign_key_name=(self.class.name.tableize.singularize+'_id').to_sym
		if ass.nil? then
			return "Association #{association_name}'s foreign key #{associations_foreign_key_name} has value #{ass[self.class.name.to_s+'_id']} but the association returns nil."
		elsif ass.empty? then
			ret= "Association #{association_name} with foreign key #{associations_foreign_key_name} is empty; "
			case self.class.association_class(association_name).association_macro_type(self.class.name.tableize.singularize)
			when :has_many
				return ret+"but has many."
			when :belongs_to
				return ret+"but belongs_to."
			when :neither_has_many_nor_belongs_to
				return ret+"because neither_has_many_nor_belongs_to."
			else
				return "New return value from #{self.class.name}.association_macro_type(#{association_name})=#{self.class.association_macro_type(association_name)}."
			end #case
		else
			associations_foreign_key_values=ass.map { |a| a.send(associations_foreign_key_name) }.uniq.join(',')
			return "Association #{association_name}'s foreign key #{associations_foreign_key_name} has value #{associations_foreign_key_values},#{ass.inspect} and returns type #{ass.class.name}."
		end
		
	when :not_generic_table
		return "#{self.class.name} does not recognize #{association_name} as a generic table."
	when:not_an_association
		return "#{self.class.name} does not recognize #{association_name} as association."
	else
		return "New return value from #{self.class.name}.association_arity(#{association_name})=#{self.class.association_arity(association_name)}."
	end #if
end #def
def association_has_data(association_name)
	return association_state(association_name)[/ and returns type /,0]
end #def
def associated_to_s(association_name,method,*args)
	if self[association_name.to_s+'_id'].nil? then # foreign key uninitialized
		return ''
	else
		ass=send(association_name)
		if ass.nil? then
			return ''
		else
			return ass.send(method.to_sym,*args).to_s
		end
	end
end #def
def Match_and_strip(regexp=/=$/)
	matching_methods(regexp).map do |m|
		m.sub(regexp,'')
	end
end #def
def Generic_Table.eval_constant(constant_name)
	constant_name.constantize
rescue NameError
	return nil
end #def
def Generic_Table.is_table?(table_name)
	raise "table_name must include only [A-Za-z0-9_]." if (table_name =~ /^[A-Za-z0-9_]+$/).nil?
	if Generic_Table.table_exists?(table_name) then
		return true
	#~ elsif Generic_Table.table_exists?(table_name.tableize) then
		#~ return true
	else
		return false
	end #if
end #def
def Generic_Table.is_ActiveRecord_table?(model_class_name)
	if Generic_Table.is_table?(model_class_name.tableize) then
		model_class=Generic_Table.eval_constant(model_class_name.classify)
		model_class.new.kind_of?(ActiveRecord::Base)
	else
		return false
	end #if
end #def
def display_full_time(time)
	time.rfc2822
end #def

end # module


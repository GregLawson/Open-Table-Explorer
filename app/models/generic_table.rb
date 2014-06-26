###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/global.rb'
require_relative '../../app/models/generic_table_html.rb' # in test_helper?
require_relative '../../app/models/generic_table_association.rb' # in test_helper?
require_relative '../../app/models/generic_grep.rb' # in test_helper?
require_relative '../../app/models/column_group.rb'
require_relative '../../app/models/generic_table_association.rb'
require_relative '../../app/models/common_table.rb'
#require 'test/assertions/generic_table_assertions.rb' # in test_helper?
# sudo apt-get install ruby-activerecord-3.2
# gem install activerecord
# gem install activerecord-mysql-adapter
require 'rubygems'
require 'active_record'
ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => 'default_schema',
  :username => 'greg',
#  :password => 'password',
  :host     => 'localhost')
# Methods in common bettween ActiveRecord::Base and NoDB
module Generic_Table
module ClassMethods
include GenericTableHtml::ClassMethods
include GenericGrep::ClassMethods
include ColumnGroup::ClassMethods
def nesting
	return Module.nesting
end #nesting
def sample_burst(sample_type, start, spacing, consecutive)
	if consecutive>spacing then
		raise "consecutive(#{consecutive})>spacing(#{spacing})"
	end #if
	case sample_type
	when :first, :random
		return all[start, consecutive]
	when :last
		return all[start+spacing-consecutive, consecutive]
	else
		raise "Unknown sample type=#{sample_type}. Expected values are :first, :Last."
	end #case
end #sample_burst
# return a statified or random sample
# returns a nested array of sample records
# Usually you will want sample.flatten
# The nested structure is available for plotting (say different colors) to see locality and trends.
def sample(samples_wanted=100, sample_type=:first, consecutive=1)
	size=all.size
	samples_returned=[samples_wanted, size].min
	bursts=(samples_returned/consecutive).ceil
	spacing=(size/bursts).ceil
	ret=(0..bursts-1).map do |burst|
		burst_start=burst*spacing
		case sample_type
		when :first, :last
			sample_burst(sample_type, burst_start, spacing, consecutive)
		when :random
			burst_start=rand(samples_returned)
			sample_burst(sample_type, burst_start, spacing, consecutive)
		else
			raise "Unknown sample type=#{sample_type}. Expected values are :first, :random, :last"
		end #case
	end #map burst
	return ret #[0..samples_returned-1]
end #sample
def model_file_name
	return "app/models/#{name.tableize.singularize}.rb"
end #model_file_name
# Whether primay logical key has been overridden 
# or ActiveRecord::Base.logical_primary_key is used.
# nil returned if overridden.
# true returned otherwise.
# from http://en.wikipedia.org/wiki/Algorithms_for_calculating_variance
# Skewness is defined at http://en.wikipedia.org/wiki/Skewness
# kurtosis is defined at http://en.wikipedia.org/wiki/Kurtosis
def one_pass_statistics(column_name)
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
# To detect collisions between attributes as methods and ActiveRecord methods.
def is_active_record_method?(method_name)
	if ActiveRecord::Base.instance_methods_from_class(true).include?(method_name.to_s) then
		return true
	else
		return false
	end #if
end #is_active_record_method
end #ClassMethods
extend ClassMethods
include GenericTableHtml
include GenericGrep
include ColumnGroup
include GenericTableAssociation
end #Generic_Table
module ActiveRecord

class Base
include Generic_Table
extend Generic_Table::ClassMethods
include GenericTableAssociation
extend GenericTableAssociation::ClassMethods
#Rails only? include ActionView::Helpers::UrlHelper


end #class Base
end #module ActiveRecord
def Match_and_strip(regexp=/=$/)
	matching_methods(regexp).map do |m|
		m.sub(regexp,'')
	end
end #Match_and_strip
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

end # Generic_Table
module NoDB # provide duck-typed ActiveRecord like functions.
attr_reader :attributes
#gone_manual! include ActiveModel # trying to fulfill Rails 3 promise that ActiveModel would allow non-ActiveRecord classes to share methods.
include Generic_Table
extend Generic_Table::ClassMethods
module ClassMethods
include Generic_Table::ClassMethods
def column_symbols
	column_names=sample.flatten.map do |r|
		r.keys.map {|name| name.downcase.to_sym}
	end.flatten.uniq #map
end #column_symbols
def table_class
	return self
end #NoDB.table_class
def table_name
	return table_class.name.tableize
end #NoDB.table_name
def default_names(values_or_size, prefix='Col_')
	if values_or_size.instance_of?(Array) then
		size=values_or_size.size
	elsif values_or_size.instance_of?(Fixnum) then
		size=values_or_size
	else
		raise "values_or_size=#{values_or_size.inspect} is a #{values_or_size.class} not an Array or Fixnum."
	end #if
	Array.new(size) {|i| prefix+i.to_s}
end #default_names
def insert_sql(record)
	values=record.values.map do |value|
		if value.instance_of?(String) then
			"'"+value.to_s+"'"
		else
			value
		end #if
	end #map
	return "INSERT INTO #{self.table_name}(#{get_field_names.join(',')}) VALUES(#{values.join(',')});\n"
end #insert_sql
def dump
	all.map do |record|
		values=insert_sql(record)
	end #map
end #dump
def data_source_yaml(yaml_table_name=table_name)
	yaml = YAML::load( File.open("test/data_sources/#{yaml_table_name}.yml" ) )
end #data_source_yaml
def get_field_names
	feild_names=all.first.keys
end #field_names
end #ClassMethods
# NoDB.new(value_array, name_array, type_array) -specified values, names, and types
# NoDB.new(value_array, type_array) - values with default names and specified types (arrayish)
# NoDB.new(value_array) - values with default names and types
# NoDB.new(value_name_hash, type_array) -specified values (Hash.values), names (Hash.keys) and types
# NoDB.new(value_name_hash)-specified values (Hash.values), names (Hash.keys), and types
# NoDB.new - empty object no attributes, no values, no names, no types. All can be added.
DEFAULT_TYPE=String
def initialize(values=nil, names=nil, types=nil)
	if values.nil? then
		@attributes=ActiveSupport::HashWithIndifferentAccess.new
		@types={}
	elsif values.instance_of?(Array) then
		if names.instance_of?(Array) then
			if !names.all?{|n| n.instance_of?(String)|n.instance_of?(Symbol)} then
				names=self.class.default_names(values)
			end #if
		else #missing names
			names=self.class.default_names(values)
		end #if
		@attributes=Hash[[names, values].transpose]
		@types=types || names
	elsif values.instance_of?(Hash) then
		@attributes=values
		@types=types || names
	else
		raised "confused about arguments to NoDB.initialize."
	end #if
end #NoDB initialize
def [](attribute_name)
	@attributes[attribute_name]
end #[]
def []=(attribute_name, value)
	@attributes[attribute_name]=value
end #[]=
def has_key?(key_name)
	return @attributes.has_key?(key_name)
end #has_key?
def keys
	return @attributes.keys
end #keys
def table_class
	return self.class
end #table_class
def table_name
	return table_class.table_name
end #table_name
def clone
	return self.new(@attributes.clone, @types.clone)
end #clone
end #NoDB


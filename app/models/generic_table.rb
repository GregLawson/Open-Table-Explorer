###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/common_table.rb'
require_relative '../../app/models/generic_table_association.rb' # in test_helper?
require_relative '../../app/models/generic_table_association.rb'
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



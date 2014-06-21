###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
require_relative '../assertions/generic_table_examples.rb'
class GenericTableHtmlTest < TestCase
include Generic_Table
include GenericTableAssertions
@@table_name='stream_patterns'
fixtures @@table_name.to_sym
def test_column_order
	assert_equal([:name, :created_at, :updated_at], StreamPattern.column_order)	
end #column_order
def test_header_html
		assert_not_empty(StreamPattern.column_names)
		assert_equal('<tr><th>Name</th><th>Created at</th><th>Updated at</th></tr>', StreamPattern.header_html)
	ActiveRecord::Base.association_refs do |class_reference, association_reference|
	end #each
end #header_html
def test_table_html
	explain_assert_respond_to(StreamPattern, :table_html)
	assert_not_nil(StreamPattern.table_html)
	assert_match(%r{<table>.*</table>}, StreamPattern.table_html)
	
end #table_html
def test_rails_route
	assert_equal("stream_patterns/#{StreamPattern.first.id}", StreamPattern.first.rails_route)
	assert_equal("stream_method_calls/64810937", StreamMethodCall.first.rails_route)
end #rails_route
def test_column_html
	acq=StreamPattern.find_by_name('Acquisition')
	assert_equal("Acquisition", acq.column_html(:name))
	expected_td_html="<td>Acquisition</td>"
	assert_equal(expected_td_html, '<td>'+acq.column_html(:name)+'</td>')
	assert_instance_of(StreamPattern, acq)
	assert_kind_of(ActiveRecord::Base, acq)
	assert_equal(ActiveRecord::Base, acq.class.superclass)
	assert_kind_of(ActiveRecord::Base, acq)
	assert_equal([Generic_Table, GenericTableAssertions, GenericGrep, GenericTableHtml, GenericTableAssociation], acq.class.included_modules.select {|m| m.name[0..6]=='Generic'})
end #column_html
def test_row_html
	acq=StreamPattern.find_by_name('Acquisition')
	assert_match(/tr/, acq.row_html)
	expected_html="<tr><td>Acquisition</td>"
	expected_html_length=expected_html.length
	assert_equal(expected_html, acq.row_html[0,expected_html_length])
end #row_html
end #GenericTableHtml

###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require 'test/test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class EEGTest < ActiveSupport::TestCase
@@test_name=self.name
@@model_name=@@test_name.sub(/Test$/, '').sub(/Controller$/, '')
@@model_class=@@model_name.constantize
@@table_name=@@model_name.tableize
#file not fixture fixtures @@table_name.to_sym
def test_initialize
end #initialize
def test_all
	assert_include('href', Url.column_names)
	assert_not_empty(Url.where("href='EEG2'"),"Url.all=#{Url.all.inspect}")
	assert_not_nil(Url.where("href='EEG2'").first)
	assert_not_empty(Url.where("href='EEG2'").first.url)
	uri=Url.where("href='EEG2'").first
	assert_not_nil(uri)
	file_method=StreamMethod.find_by_name('File')
	assert_equal('File',file_method.name)
	file_method[:uri]=uri
	assert_instance_of(Url, file_method[:uri])
	assert(file_method.has_attribute?(:uri))
	file_method.compile_code!
	assert(!file_method.has_attribute?(:errors))
	assert_equal(ActiveModel::Errors.new('err'), file_method.errors)
	assert_equal([], file_method.errors.full_messages)
	firing=file_method.fire!
	
	assert_equal([], firing.errors[:interface_code],"interface_code=#{firing[:interface_code]}")
	assert_equal([], firing.errors[:acquisition])
	assert_not_empty(firing.errors)
	assert_not_empty(firing.errors.inspect)
	assert_instance_of(ActiveModel::Errors, firing.errors)
	assert_instance_of(Array, firing.errors.full_messages)
	assert_instance_of(StreamMethod, firing)
	assert_kind_of(StreamMethod, firing)
	assert_equal(firing, file_method)
	assert_not_empty(file_method[:acquisition])
	assert_instance_of(String, file_method[:acquisition])
	delimited_method=StreamMethod.find_by_name('Delimited')
	assert_not_nil(delimited_method)
	delimited_method[:unparsed]=file_method[:acquisition]
	selection=GenericType.find_by_name('tab')
	assert_not_nil(selection)
	delimited_method[:selection]=selection
	delimited_method.compile_code!
	delimited_method.fire!
	assert_equal([], delimited_method.errors[:interface_code],"interface_code=#{delimited_method[:interface_code]}")
	assert_equal([], delimited_method.errors[:acquisition])
	assert_not_empty(delimited_method.errors)
	assert_not_empty(delimited_method.errors.inspect)
	assert_instance_of(ActiveModel::Errors, delimited_method.errors)
	assert_instance_of(Array, delimited_method.errors.full_messages)
	assert_instance_of(StreamMethod, delimited_method)
	assert_kind_of(StreamMethod, delimited_method)
	all=EEG.all
	assert_instance_of(String, all)
	assert_not_empty(all)
end #all
def test_associations
	assert_equal("695672806",StreamPattern.find_by_name('Acquisition').id.inspect)
	streamCall=StreamMethodCall.first
	assert_equal(64810937,streamCall.id)
	assert_equal_sets(["stream_method","stream_links"], StreamMethodCall.association_names)
	assert_equal('Acquisition',StreamPatternArgument.where("name='Acquisition'").first[:name])
#	assert_equal([],StreamMethodArgument.where("stream_pattern='Acquisition'").name)
end #test_associations
end #EEG

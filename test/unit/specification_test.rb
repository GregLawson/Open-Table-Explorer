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
class SpecificationTest < ActiveSupport::TestCase

def test_initialize
	spec=Specification.new(:name => :Streams)
	assert_not_nil(spec)
	assert_instance_of(Specification, spec)
end #initialize
def test_all
	assert_not_nil(StreamMethod.all)
	assert(StreamMethod.all.each{|s| assert_kind_of(String, s.name)})
	assert(StreamMethod.all.each{|s| assert_association(StreamMethod, :stream_pattern)})
	assert_equal(:to_one, StreamMethod.association_arity(:stream_pattern))
	assert_equal(:to_many, StreamPattern.association_arity(:stream_methods))
	assert_equal("grep \"^belongs_to :stream_pattern\" app/models/stream_method.rb &>/dev/null", StreamMethod.model_grep_command(StreamMethod.association_grep_pattern('^belongs_to ', :stream_pattern)))
	assert_equal('^belongs_to :stream_pattern', StreamMethod.association_grep_pattern('^belongs_to ', :stream_pattern))
	assert(StreamMethod.belongs_to_association?(:stream_pattern))
	assert_association(StreamPattern, :stream_methods)
	assert_equal(:has_many, StreamPattern.association_macro_type(:stream_methods))
	assert(StreamPattern.has_many_association?(:stream_method))
	assert(!StreamPattern.belongs_to_association?(:stream_method))
	assert_equal(:belongs_to, StreamMethod.association_macro_type(:stream_pattern))
	assert_equal(:has_many, StreamPattern.association_macro_type(:stream_methods))
	StreamMethod.all.each do|s| 
		assert_not_nil(s.stream_pattern, "s=#{s.inspect}, StreamPattern.find_by_id(s.stream_pattern_id)=#{StreamPattern.find_by_id(s.stream_pattern_id)}")
	end #each
	StreamMethod.all.each do|s| 
		assert_kind_of(String, s.stream_pattern.name)
	end #each
	assert_not_nil(StreamMethod.all.map{|s| {:name => s.name, :spec_kind => :StreamMethod, :parent => s.stream_pattern.name.to_s}})
	methods=StreamMethod.all.map{|s| {:name => s.name, :spec_kind => :StreamMethod, :parent => s.stream_pattern.name.to_s}}
	assert_association(StreamMethod, :stream_pattern)
	assert_matching_association(StreamMethod, :stream_pattern)
	StreamMethod.all.map do |s|
#dubious		assert_foreign_key_points_to_me(s, :stream_pattern)
		assert_not_nil(s.stream_pattern, "s=#{s.inspect}, s.methods=#{s.methods.inspect}")
	end #map
	assert_not_empty(Specification.all)
	assert_instance_of(Array,Specification.all)
	assert_instance_of(Specification,Specification.all[0])
	# find specifications for EEG
	eeg_url=Urls.find_by_name('emo')
	file_acquisition=Stream_Method.find_by_name('File')
	parser=Stream_Method.find_by_name('Split')
	# find specifications for bug files
end #all
def test_attribute_assignment
	spec=Specification.new(:name => :Streams)
	assert_not_nil(spec)
	assert_not_nil(spec[:name], "spec=#{spec.inspect}")
	assert_instance_of(Specification, spec)
	assert_equal(:Streams, spec[:name])
end #[]=
def test_find_by_name
#fail	assert_not_nil(Specification.find_by_name(:Streams))
	assert_not_nil(Specification.find_by_name(:Ifconfig))
	assert_not_nil(Specification.find_by_name(:Nmap))
end #find_by_name
end #Specification

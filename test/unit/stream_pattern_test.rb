###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative 'default_test_case.rb'
class StreamPatternTest < TestCase
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
	define_model_of_test # allow generic tests
	assert_module_included(TE.model_class?,Generic_Table)
	explain_assert_respond_to(TE.model_class?,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(TE.model_class?,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	define_association_names
end #def
def test_general_associations
	assert_general_associations(@table_name)
end #test
def test_id_equal
	assert(!model_class?.sequential_id?, "model_class?=#{model_class?}, should not be a sequential_id.")
	assert_test_id_equal
end #test_id_equal
def test_specific__stable_and_working
	assert_equal(@my_fixtures,fixtures(@table_name))	
end #test
def test_all
	@fullTable=StreamPatternArgument.all
	assert_operator(@fullTable.size, :>, 0)
end #all
def test_aaa_test_new_assertions_ # aaa to output first
	@stream_pattern=StreamPattern.find_by_name('Acquisition')
	assert_equal('Acquisition',@stream_pattern.name)
	assert_not_nil(@stream_pattern.id)
	@association=StreamPatternArgument.find_all_by_stream_pattern_id(@stream_pattern.id )
	assert_equal(2,@association.size)

	if Generic_Table.is_generic_table?(@stream_pattern.class.name) then 
		assert(@stream_pattern.class.is_matching_association?(:stream_pattern_arguments))
		assert_equal(:to_many,@stream_pattern.class.association_arity(:stream_pattern_arguments)) 
		assert_equal(:has_many,@stream_pattern.class.association_macro_type(:stream_pattern_arguments)) 
		assert_equal(:to_many_has_many,@stream_pattern.class.association_type(:stream_pattern_arguments) )
#		assert_equal("Association stream_pattern_arguments with foreign key stream_pattern_id is empty; but belongs_to.",@stream_pattern.association_state(:stream_pattern_arguments) )
		if @stream_pattern.association_has_data(:stream_pattern_arguments) then 
			if StreamPatternArgument.find_all_by_stream_pattern_id(@stream_pattern.id ) then 
				StreamPatternArgument.find_all_by_stream_pattern_id(@stream_pattern.id )
			else
				StreamPatternArgument.all
			end #if 
			#~ puts @stream_pattern.stream_pattern_arguments.inspect
			system(@stream_pattern.class.association_grep('has_many',:stream_pattern_arguments))
			system(StreamPatternArgument.association_grep('belongs_to',:stream_patterns)) 
		end #if 
	end #if 
end #test

end #class

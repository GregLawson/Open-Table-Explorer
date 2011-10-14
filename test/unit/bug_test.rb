require 'test_helper'
# executed in alphabetical orer? Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class BugTest < ActiveSupport::TestCase
fixtures :bugs
def test_parse_bug
	test_type=:unit
	singular_table=:code_base
	plural_table=singular_table.to_s.pluralize
	testRun=TestRun.new(test_type,singular_table, plural_table,nil)
	header,errors,summary=TestRun.parse_log_file(testRun.log_file)
	errors.each do |error|
	error.scan(/  ([0-9]+)[)] ([A-Za-z]+):\n(test_[a-z_]*)[(]([a-zA-Z]+)[)]:?\n(.*)$/m) do |number,error_type,test,klass,report|
		puts "number=#{number.inspect}"
		puts "error_type=#{error_type}"
		puts "test=#{test.inspect}"
		puts "klass=#{klass.inspect}"
		puts "report=#{report.inspect}"
		url="rake testing:#{test_type}_test TABLE=#{singular_table} TEST=#{test}"
		if error_type=='Error' then
			report.scan(/^([^\n]*)\n(.*)$/m) do |error,trace|
				puts "error=#{error.inspect}"
				puts "trace=#{trace.inspect}"
				open('db/bugs.sql',"a" ) {|f| f.write("insert into bugs(url,error,context,created_at,updated_at) values('#{url}','#{error.tr("'",'`')}','#{trace}','#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }						
			end #scan
		elsif error_type=='Failure' then
			report.scan(/^\s*[\[]([^\]]+)[\]]:\n(.*)$/m) do |trace,error|
				error=error.slice(0,50)
				puts "error=#{error.inspect}"
				puts "trace=#{trace.inspect}"
				open('db/bugs.sql',"a" ) {|f| f.write("insert into bugs(url,error,context,created_at,updated_at) values('#{url}','#{error.tr("'",'`')}','#{trace}','#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }						
			end #scan
		else
			puts "pre_match=#{s.pre_match}"
			puts "post_match=#{s.post_match}"
			puts "before #{s.rest}"
		end #if
		assert_not_nil(error_type)
		assert_include(error_type,['Error','Failure'])
	end #scan
		puts "error='#{error}'"
		assert_not_nil(Bug.new(test_type,singular_table,error))
	assert_not_nil(Bug.new())
	end #each
	
end #parse_bug
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
	define_model_of_test # allow generic tests
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
#	define_association_names #38271 associations
end #def
test "fixture_function" do  # aaa to output first
#?	define_association_names #38271 associations
#csv	assert_equal(@my_fixtures,fixtures(@table_name))
end #test
def test_general_associations
#	assert_general_associations(@table_name)
end #test
def test_id_equal
	if @model_class.sequential_id? then
	else
		@my_fixtures.each_value do |ar_from_fixture|
			message="Check that logical key (#{ar_from_fixture.class.logical_primary_key}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label for record."
			message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,message)
		end
	end
end #def
test "specific, stable and working" do
end #test
test "aaa test new assertions" do  # aaa to output first
#csv	assert_equal(@my_fixtures,fixtures('bugs'))
end #test

end #class

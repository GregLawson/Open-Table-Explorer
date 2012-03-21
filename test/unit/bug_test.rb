require 'test/test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class BugTest < ActiveSupport::TestCase
@@test_name=self.name
#        assert_equal('Test',@@test_name[-4..-1],"@test_name='#{@test_name}' does not follow the default naming convention.")
@@model_name=@@test_name.sub(/Test$/, '').sub(/Controller$/, '')
@@table_name=@@model_name.tableize
#@@my_fixtures=fixtures(@@table_name)
 
fixtures @@table_name.to_sym
def test_initialize
	assert_not_nil(Bug.new())
	test_type=:unit
	singular_table=:code_base
	plural_table=singular_table.to_s.pluralize
	testRun=TestRun.new(test_type,singular_table, plural_table,nil)
	header,errors,summary=TestRun.parse_log_file(testRun.log_file)
	errors.each do |error|
		assert_not_nil(error)
		assert_not_empty(error)
		assert_instance_of(String, error)
		regexp=/  ([0-9]+)[)] ([A-Za-z]+):\n(test_[a-z_]*)[(]([a-zA-Z]+)[)]:?\n(.*)$/m
		regexp_source=regexp.source
		match_data=(regexp).match(error)
		regexp_tree=RegexpMatch.new(regexp_source, error)
		assert_equal([], regexp_tree.matchSubTree)
		assert_not_nil(match_data, "error=#{error.inspect}")
		@number,@error_type,@test,@klass,@report=match_data[1..-1]
		puts "number=#{@number.inspect}"
		puts "error_type=#{@error_type}"
		puts "test=#{@test.inspect}"
		puts "klass=#{@klass.inspect}"
		puts "report=#{@report.inspect}"
		@url="rake testing:#{@test_type}_test TABLE=#{singular_table} TEST=#{@test}"
		if @error_type=='Error' then
			match_data=/^([^\n]*)\n(.*)$/m.match(@report)
			assert_not_nil(match_data)
			@error,@trace=match_data[1..-1]
			@context=@trace.split("\n")
	#		puts "error='#{@error.inspect}'"
	#		puts "trace=#{@trace.inspect}"
	#		open('db/bugs.sql',"a" ) {|f| f.write("insert into bugs(url,error,context,created_at,updated_at) values('#{url}','#{error.tr("'",'`')}','#{trace}','#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }						
		elsif @error_type=='Failure' then
			@error,@trace=@report.scan(/^\s*[\[]([^\]]+)[\]]:\n(.*)$/m)
				@context=@trace.split("\n")
				error=error.slice(0,50)
				puts "error='#{@error.inspect}'"
				puts "trace='#{@trace.inspect}'"
				puts "context='#{@context.inspect}'"
				open('db/bugs.sql',"a" ) {|f| f.write("insert into bugs(url,error,context,created_at,updated_at) values('#{url}','#{error.tr("'",'`')}','#{trace}','#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }						
		else
			puts "error='#{@error.inspect}'"
#			puts "pre_match=#{match_data.pre_match}"
#			puts "post_match=#{match_data.post_match}"
#			puts "before #{match_data.rest}"
		end #if
		assert_not_nil(@error_type)
		assert_include(@error_type,['Error','Failure'])
	puts "@error='#{@error}'"
	bug=Bug.new(test_type,singular_table,error)
	assert_not_nil(bug)
	assert_not_nil(bug[:id])
	assert_not_nil(bug[:gui])
	assert_not_nil(bug[:resolution])
	assert_not_nil(bug[:created_at])
	assert_not_nil(bug[:updated_at])
	assert_not_nil(bug[:error_type_id])
	asert_equal(@url,bug[:url])
	asert_equal(@error,bug[:error])
	asert_equal(@context,bug[:context])	
	end #each
	
end #parse_bug
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
	define_model_of_test # allow generic tests
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement. Sequential id is a class method.")
	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
#	define_association_names #38271 associations
end #setup
def test_fixture_function_ # aaa to output first
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
def test_specific__stable_and_working
end #test
def test_aaa_test_new_assertions  # aaa to output first
#csv	assert_equal(@my_fixtures,fixtures('bugs'))
end #test

end #class

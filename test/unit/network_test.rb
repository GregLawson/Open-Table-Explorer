###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class NetworkTest < TestCase
@@test_name=self.name
#        assert_equal('Test',@@test_name[-4..-1],"@test_name='#{@test_name}' does not follow the default naming convention.")
@@model_name=@@test_name.sub(/Test$/, '').sub(/Controller$/, '')
@@table_name=@@model_name.tableize
#@@my_fixtures=fixtures(@@table_name)
 
#fixtures @@table_name.to_sym
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
#	define_model_of_test # allow generic tests
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement. Sequential id is a class method.")
	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	define_association_names
end #def
def test_whereAmI
	acquire=StreamPattern.find_by_name('Acquisition')
	assert_not_nil(acquire, "StreamPattern=#{StreamPattern.all.map{|p| p.name}.inspect}")
	ifconfig=StreamMethod.find_by_name('Shell')
	assert_not_nil(ifconfig, "StreamMethod=#{StreamMethod.all.inspect}")
	explain_assert_respond_to(ifconfig, :compile_code)
	explain_assert_respond_to(ifconfig, :fire)
	Network.whereAmI
end #whereAmI
def test_general_associations
#more fixtures need to be loaded?	assert_general_associations(@table_name)
end #test
def test_id_equal
	if @model_class.sequential_id? then
	else
		@my_fixtures.each_value do |ar_from_fixture|
			message="Check that logical key (#{ar_from_fixture.logical_primary_key}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label for record."
			message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,message)
		end
	end
end #def
def test_specific__stable_and_working
end #test
def test_aaa_test_new_assertions_ # aaa to output first
	assert_equal(fixtures(@table_name), @my_fixtures)
end #test
end #class
def test_NetworkInterface
	lines=parse(NetworkInterface::IFCONFIG.output, LINES)
	double_lines=NetworkInterface::IFCONFIG.output.split("\n\n")
	assert_instance_of(Array, double_lines)
	assert_operator(2, :<=, double_lines.size)
	assert_equal('eth0', double_lines[0].split(' ')[0])
	words=parse(double_lines[0], WORDS)
	assert_equal('eth0', words[0])
#	assert_equal('Link', words[1], "words=#{words.inspect}, lines=#{lines.inspect}")
	puts "words=#{words.inspect}, double_lines=#{double_lines.inspect}"
	words=double_lines.map do |row|
		words=parse(row, WORDS)
		puts "words=#{words.inspect}, row=#{row.inspect}"
		assert_match(words[0], /eth0|lo|wlan0/, "row=#{row.inspect}, words=#{words.inspect}")
	end #map
	parse(NetworkInterface::IFCONFIG.output, LINES).map  do |row| 
		parse(row, WORDS)
	end #map
#	assert_equal('', NetworkInterface::IFCONFIG.rows_and_columns)
#	assert_equal('eth0,', NetworkInterface::IFCONFIG.inspect)
#	assert_equal('', NetworkInterface::IFCONFIG.output)
end #NetworkInterface

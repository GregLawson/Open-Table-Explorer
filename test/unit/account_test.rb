require 'test_helper'

class AccountTest < ActiveSupport::TestCase
def setup
	define_association_names
	@model_class=eval(@model_name)
	@record_keys=@loaded_fixtures[@table_name].collect do |fix|
#		puts "fix.at(0)=#{fix.at(0).inspect}"
		fix.at(0)
	end #collect
	@my_fixtures=@record_keys.collect do |rk|
		accounts(rk)
	end #each
	@possible_associations=@model_class.instance_methods(false).select { |m| m =~ /=$/ and !(m =~ /_ids=$/) and is_association?(@my_fixtures.first,m[0..-2].to_sym)}.collect {|m| m[0..-2] }
 	@possible_many_associations=@model_class.instance_methods(false).select { |m| (m =~ /_ids=$/) and is_association_to_many?(@my_fixtures.first,m[0..-2].to_sym)}.collect {|m| m[0..-2] }
	@possible_foreign_keys=foreign_key_names(@model_class)
end
end
def test_id_equal
	@my_fixtures.each do |my_fixture|
		assert_equal(Fixtures::identify(my_fixture.model_class_name),my_fixture.id,"identify != id")
	end
end #def

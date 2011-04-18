require 'test_helper'
class TransferTest < ActiveSupport::TestCase
def setup
	define_association_names
end
def test_general_associations
#kludge	assert_general_associations(@table_name)
end
def test_id_equal
	if @model_class.new.sequential_id? then
	else
		@my_fixtures.each_value do |ar_from_fixture|
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,"identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}")
		end
	end
end #def
def test_aaa_test_assertions # aaa to output first
#	puts "fixtures(@table_name)=#{fixtures(@table_name)}"
#	assert_not_nil(fixtures('transfers')[5])
end
class Transfer < ActiveRecord::Base
belongs_to :account
include Generic_Table
@@transfers=Arel::Table.new(:transfers)
@@accounts=Arel::Table.new(:accounts)
def Transfer.transfers
	return @@transfers
end #def
#scope :transfers_extended, join(@@accounts).on(@@transfers[:account_id].eq(@@accounts[:id])).project(:open_tax_solver_line,:amount)
def Transfer.transfers_extended
	@@transfers.join(@@accounts).on(@@transfers[:account_id].eq(@@accounts[:id])).project(:open_tax_solver_line,:amount)
end #def
def Transfer.ots_lines
	@@accounts.project(:open_tax_solver_line)
end #def
def Transfer.open_tax_solver
	ots_data="Title:  US Federal 1040 Tax Form - 2010 - Generated\n\nStatus     Married/Joint {Single, Married/Joint, Head_of_House, Married/Sep, Widow(er)}\nDependents     2         {Number of Dependents, self=1, spouse, etc.}\n{Income}\n"
	Account.ots_line_values.each do |ots_line|
		ots_data="#{ots_line} # {transfer.amount.to_s}<BR>\n"
	end # each
end #def
end
def assert_relation(relation)
	assert_kind_of(ActiveRecord::Relation,relation)
	explain_assert_respond_to(relation,:to_sql)	
	testCall(relation,:to_sql)
	explain_assert_respond_to(relation,:each)	
end #def
test "each" do
	transfers = Transfer.where(:amount => 100.0) # No Query
	assert_relation(transfers)
	transfers.each {|c| puts c.amount } # Fires "select * from cars where ..."
	assert_relation(transfers)
	accounts=Account.scoped
	assert_relation(Account.ots_line_values)
end #test
test "stable and working" do	
	transfers=Transfer.transfers
	
	assert_kind_of(ActiveRecord::Relation,Transfer.scoped)
	assert_kind_of(Arel::SelectManager,Transfer.transfers_extended)
	explain_assert_respond_to(Transfer.transfers_extended,:to_sql)	
	testCall(Transfer.transfers_extended,:to_sql)
	assert_equal(Transfer.transfers_extended.to_sql,"SELECT open_tax_solver_line, amount FROM \"transfers\" INNER JOIN \"accounts\" ON \"transfers\".\"account_id\" = \"accounts\".\"id\"")

	testCall(Transfer.joins(accounts),:to_sql)

	relational_algebra=Transfer.transfers_extended
	
	expected_sql='SELECT open_tax_solver_line, amount FROM "transfers" INNER JOIN "accounts" ON "transfers"."account_id" = "accounts"."id"'
	assert_equal(expected_sql,relational_algebra.to_sql)
	arel_methods=["where","having","from","group","project",'joins','order']
end #test
test "relations" do
	assert_relation(Transfer.scoped)
	assert_relation(Account.ots_line_values)
end #test
test "open_tax_solver" do
	Transfer.open_tax_solver
end #test
end #class

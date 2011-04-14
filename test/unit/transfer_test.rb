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
	assert_not_nil(fixtures('transfers')[5])
end
class Transfer < ActiveRecord::Base
belongs_to :account
include Generic_Table
@@transfers=Arel::Table.new(:transfers)
@@accounts=Arel::Table.new(:accounts)
def Transfer.transfers
	return @@transfers
end #def
def Transfer.account_join
	@@transfers.join(@@accounts).on(@@transfers[:account_id].eq(@@accounts[:id])).project(:open_tax_solver_line,:amount)
end #def
def Transfer.open_tax_solver
	transfers = arel
	ots_data="Title:  US Federal 1040 Tax Form - 2010 - Generated\n\nStatus     Married/Joint {Single, Married/Joint, Head_of_House, Married/Sep, Widow(er)}\nDependents     2         {Number of Dependents, self=1, spouse, etc.}\n{Income}\n"
	#~ transfers.account_join.each do |transfer|
		#~ ots_data="#{ots_data} #{number_to_currency(transfer.amount).to_s}<BR>\n"
	#~ end # each
end #def
end
test "open_tax_solver" do
#	transfers=fixtures('transfers').values.first.class.arel
#	transfers=Arel::Table.new(:transfers)
	transfers=Transfer.transfers
	puts "transfers.columns=#{transfers.columns.collect {|col| col.name}.inspect}"
	puts transfers.class
	puts Transfer.class
	
	@relation = Arel::Table.new(:users)
	sm = @relation.skip 2
        puts sm.to_sql
	assert_not_empty(sm.to_sql)
	explain_assert_respond_to(transfers,:join)
	explain_assert_respond_to(sm,:to_sql)
	assert_kind_of(Arel::Table,transfers)
	tm=transfers.skip 2
	explain_assert_respond_to(tm,:to_sql)

	assert_kind_of(Arel::SelectManager,transfers.skip(2))
	assert_kind_of(Arel::SelectManager,transfers.project(:open_tax_solver_line,:amount))
	assert_kind_of(Arel::SelectManager,transfers.join(accounts))
	assert_kind_of(Arel::SelectManager,transfers.join(accounts).project(:open_tax_solver_line,:amount))
	assert_kind_of(Arel::SelectManager,transfers.project(:open_tax_solver_line,:amount).join(accounts))

	assert_kind_of(Arel::Table,Transfer.transfers)
	assert_kind_of(Arel::SelectManager,Transfer.account_join)

	explain_assert_respond_to(transfers.skip(2),:to_sql)
	explain_assert_respond_to(transfers.project(:open_tax_solver_line,:amount),:to_sql)
	explain_assert_respond_to(transfers.join(accounts),:to_sql)
	explain_assert_respond_to(transfers.join(accounts).project(:open_tax_solver_line,:amount),:to_sql)
	explain_assert_respond_to(transfers.project(:open_tax_solver_line,:amount).join(accounts),:to_sql)
	explain_assert_respond_to(Transfer.account_join,:to_sql)

	testCall(transfers.skip(2),:to_sql)
	testCall(transfers.project(:open_tax_solver_line,:amount),:to_sql)
	assert_equal(transfers.project(:open_tax_solver_line,:amount).to_sql,"SELECT open_tax_solver_line, amount FROM \"transfers\"")
	
	testCall(Transfer.account_join,:to_sql)
	assert_equal(Transfer.account_join.to_sql,"SELECT open_tax_solver_line, amount FROM \"transfers\" INNER JOIN \"accounts\" ON \"transfers\".\"account_id\" = \"accounts\".\"id\"")

	#~ assert_raise(TypeError,testCall(transfers.project(:open_tax_solver_line,:amount).join(accounts),:to_sql))
	#~ assert_raise(TypeError,testCall(transfers.join(accounts).project(:open_tax_solver_line,:amount),:to_sql))
	#~ assert_raise(TypeError,testCall(transfers.join(accounts),:to_sql))

	testCall(Transfer.joins(accounts),:to_sql)

	relational_algebra=Transfer.account_join
#	relational_algebra=transfers.join(accounts).project(:open_tax_solver_line,:amount)
	testCall(relational_algebra,:to_sql)
	
	explain_assert_respond_to(transfers.project(:open_tax_solver_line,:amount).join(accounts),:to_sql)

#	expected_sql=' select open_tax_solver_line,amount from transfers,accounts where accounts.id=transfers.account_id;'
	expected_sql='SELECT open_tax_solver_line, amount FROM "transfers" INNER JOIN "accounts" ON "transfers"."account_id" = "accounts"."id"'
#	relational_algebra=transfers.project(:open_tax_solver_line,:amount).join(accounts)
#	relational_algebra=transfers.join(accounts).project(:open_tax_solver_line,:amount)
	puts relational_algebra.to_sql
	assert_equal(expected_sql,relational_algebra.to_sql)
	arel_methods=["where","having","from","group","project",'joins','order']
	
#	assert_equal(Set.new(arel_methods),Set.new(transfers.class.instance_methods(true)))
	accounts=Arel::Table.new(:accounts)
	puts "accounts.columns=#{accounts.columns.collect {|col| col.name}.inspect}"
	puts accounts.class
	
	puts(transfers.project(Arel.sql('*')).to_sql)
	puts(transfers.where(transfers[:amount].eq(100.00)).to_sql)
	puts(transfers.project(transfers[:id]).to_sql)
	puts(transfers.where("accounts.open_tax_solver_line is not null").to_sql)
	
	join=transfers.join(accounts).on(transfers[:account_id].eq(accounts[:id]))
	assert_not_nil(join)
#	assert_not_nil(transfers.includes(:accounts).where("accounts.open_tax_solver_line is not null"))
	
	assert_not_nil(transfers)
#	assert_nil(transfers.class.instance_methods(false))
	puts fixtures('transfers').values.first.class.arel.inspect
	
	puts fixtures('transfers').values.first.account_join.inspect
	puts fixtures('transfers').values.first.class.open_tax_solver
	explain_assert_respond_to(transfers,:join)
end #test
end #class

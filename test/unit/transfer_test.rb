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
@@transfers=Transfer.scoped
@@accounts=Account.scoped
def Transfer.transfers
	return @@transfers
end #def
#scope :transfers_extended, join(@@accounts).on(@@transfers[:account_id].eq(@@accounts[:id])).project(:open_tax_solver_line,:amount)
def Transfer.transfers_extended
#	@@transfers.joins(@@accounts).on(@@transfers[:account_id].eq(@@accounts[:id])).select(:open_tax_solver_line,:amount)
	@@transfers.joins(@@accounts).select('*')
end #def
def Transfer.ots_lines
	@@accounts.project(:open_tax_solver_line)
end #def
def Transfer.open_tax_solver
	ots_data="Title:  US Federal 1040 Tax Form - 2010 - Generated\n\nStatus     Married/Joint {Single, Married/Joint, Head_of_House, Married/Sep, Widow(er)}\nDependents     2         {Number of Dependents, self=1, spouse, etc.}\n{Income}\n"
	Account.ots_line_values.each do |ots_line|
		ots_data="#{ots_line} # {transfer.amount.to_s}<BR>\n"
	end # each
	return ots_data
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
	assert_relation(Transfer.transfers_extended)
	Transfer.transfers_extended.each do |t|
		puts t.inspect
	end # each
end #test
test "stable and working" do	
	transfers=Transfer.transfers
	
	assert_kind_of(ActiveRecord::Relation,Transfer.scoped)
	assert_kind_of(ActiveRecord::Relation,Transfer.transfers_extended)
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
	assert_relation(Transfer.transfers)
	assert_relation(Transfer.scoped)
	assert_relation(Account.scoped.select(:open_tax_solver_line))
	assert_relation(Account.ots_line_values)
	assert_relation(Transfer.transfers_extended)
end #test
test "open_tax_solver" do
	Transfer.open_tax_solver
end #test
test "join" do
# Our relation variables(RelVars)
T=Arel::Table.new(:transfers, :as => 'T')
A =Arel::Table.new(:accounts, :as => 'A')

# perform operations on relations
G =T.join(A)  #(implicit) will reference final joined relationship

#(explicit) predicate = Arel::Predicates::Equality.new T[:account_id], A[:id]
G =T.join(A).on( T[:account_id].eq(A[:id] )) 

# Keep in mind you MUST PROJECT for this to make sense
G.project(T[:account_id], A[:login_count].sum.as('amount'))

# Now you can group
G=G.group(T[:account_id])

#from this group you can project and group again (or group and project)
# for the final relation
TL=G.project(G[:amount].as('logins'),G[:id].count.as('users')).group(G[:amount])

end #test
test "canonical" do
	assert_match('#<Transfer id: 5, account: nil, amount: 13.55, posted: "2010-12-31"',fixtures('transfers')[5].canonicalName)
	assert_match('Account ',Account.new.canonicalName)
	assert_match('Transfer',Transfer.new.canonicalName)
	assert_kind_of(Account,Account.new)
	assert_match('Class',Account.canonicalName)
	assert_match('Class',Transfer.canonicalName)
	assert_kind_of(ActiveRecord::Relation,Transfer.transfers_extended)
	assert_relation(Transfer.transfers_extended)
	assert_respond_to(Transfer.transfers_extended,:to_s)
	assert_relation(Transfer.transfers_extended.respond_to?(:to_s))
	assert_relation(Transfer.transfers_extended.canonicalName)
end #test
end #class

require_relative 'test_environment'
require 'active_support' # for singularize and pluralize
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class TransferTest < TestCase
def setup
	define_model_of_test # allow generic tests
	assert_module_included(TE.model_class?,Generic_Table)
	explain_assert_respond_to(TE.model_class?,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(TE.model_class?,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	define_association_names
end #def
def test_general_associations
#kludge	assert_general_associations(@table_name)
end
def test_id_equal
	if TE.model_class?.sequential_id? then
	else
		@my_fixtures.each_value do |ar_from_fixture|
			message="Check that logical key (#{ar_from_fixture.logical_primary_key}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label for record."
			message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,message)
		end
	end
end #def
def test_aaa_test_assertions # aaa to output first
#	puts "fixtures(@table_name)=#{fixtures(@table_name)}"
	refute_nil(fixtures('transfers')[5])
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
	assert_instance_of(ActiveRecord::Relation,relation)
	puts "relation.matching_methods(/to_.*/)=#{relation.matching_methods(/to_.*/).inspect}"
	assert_includes('to_sql',relation.instance_methods(true))	
#	explain_assert_respond_to(relation,:to_sql)	
	testCall(relation,:to_sql)
	explain_assert_respond_to(relation,:each)	
end #def
def test_each
	transfers = Transfer.where(:amount => 100.0) # No Query
	#~ assert_relation(transfers)
	#~ transfers.each {|c| puts c.amount } # Fires "select * from cars where ..."
	#~ assert_relation(transfers)
	#~ assert_relation(Transfer.transfers_extended)
	#~ Transfer.transfers_extended.each do |t|
		#~ puts t.inspect
	#~ end # each
end #test
def test_stable_and_working	
	transfers=Transfer.transfers
	
	assert_kind_of(ActiveRecord::Relation,Transfer.scoped)
	assert_kind_of(ActiveRecord::Relation,Transfer.transfers_extended)
#	explain_assert_respond_to(Transfer.transfers_extended,:to_sql)	
	#~ testCall(Transfer.transfers_extended,:to_sql)
	#~ assert_equal(Transfer.transfers_extended.to_sql,"SELECT open_tax_solver_line, amount FROM \"transfers\" INNER JOIN \"accounts\" ON \"transfers\".\"account_id\" = \"accounts\".\"id\"")

	#~ testCall(Transfer.joins(accounts),:to_sql)

	#~ relational_algebra=Transfer.transfers_extended
	
	#~ expected_sql='SELECT open_tax_solver_line, amount FROM "transfers" INNER JOIN "accounts" ON "transfers"."account_id" = "accounts"."id"'
	#~ assert_equal(expected_sql,relational_algebra.to_sql)
	#~ arel_methods=["where","having","from","group","project",'joins','order']
end #test
def test_relations
#	assert_relation(Transfer.transfers)
	#~ assert_relation(Transfer.scoped)
	#~ assert_relation(Account.scoped.select(:open_tax_solver_line))
	#~ assert_relation(Account.ots_line_values)
	#~ assert_relation(Transfer.transfers_extended)
end #test
def test_open_tax_solver
	Transfer.open_tax_solver
end #test
def test_join
# Our relation variables(RelVars)
T=Arel::Table.new(:transfers, :as => 'T')
A =Arel::Table.new(:accounts, :as => 'A')

# perform operations on relations
G =T.join(A)  #(implicit) will reference final joined relationship

#(explicit) predicate = Arel::Predicates::Equality.new T[:account_id], A[:id]
G =T.join(A).on( T[:account_id].eq(A[:id] )) 

# Keep in mind you MUST PROJECT for this to make sense
#G.project(T[:account_id], A[:login_count].sum.as('amount'))

# Now you can group
G=G.group(T[:account_id])

#from this group you can project and group again (or group and project)
# for the final relation
#~ TL=G.project(G[:amount].as('logins'),G[:id].count.as('users')).group(G[:amount])

end #test
def test_canonical
	assert_match('#<Transfer id: 5, account: nil, amount: 13.55, posted: "2010-12-31"',fixtures('transfers')[5].canonicalName)
	assert_match('Account ',Account.new.canonicalName)
	assert_match('Transfer',Transfer.new.canonicalName)
	assert_kind_of(Account,Account.new)
	assert_match('Class',Account.canonicalName)
	assert_match('Class',Transfer.canonicalName)
	assert_kind_of(ActiveRecord::Relation,Transfer.transfers_extended)
	#~ assert_relation(Transfer.transfers_extended)
	#~ assert_respond_to(Transfer.transfers_extended,:to_s)
	#~ assert_relation(Transfer.transfers_extended.respond_to?(:to_s))
	#~ assert_relation(Transfer.transfers_extended.canonicalName)
end #test
def assert_association_value
			puts ar_from_fixture.association_state(expected_association_symbol)
			assert_nil(ar_from_fixture[expected_association_symbol.to_s+'_id']) # foreign key uninitialized
end #def
def test_associated_to_s
		expected_association_symbol=:account
		expected_association_class=expected_association_symbol.to_s.camelize.constantize
		method_of_association=:name
		@my_fixtures.each_value do |ar_from_fixture|
			assert_includes(expected_association_symbol.to_s,ar_from_fixture.class.foreign_key_association_names)
			assert_association_to_one(ar_from_fixture,expected_association_symbol)
#			ar_from_fixture=acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym)
			assert_includes(ActiveRecord::Base,ar_from_fixture.class.ancestors)
			assert_includes(method_of_association.to_s,Account.methods)
			assert_includes(method_of_association.to_s,ar_from_fixture.account.class.methods)
			
			puts ar_from_fixture.association_state(expected_association_symbol)
			ass=ar_from_fixture.send(expected_association_symbol)
			puts ar_from_fixture.association_state(expected_association_symbol)
			#~ refute_nil(ass,ar_from_fixture.association_state(expected_association_symbol))
			#~ refute_nil(ass.send(method_of_association))
			
			puts ar_from_fixture.associated_to_s(expected_association_symbol,method_of_association)
			puts Account.all.map {|r| r.id}.uniq.sort.inspect
		end #each_value
	
end #test
end #class

class Transfer< ActiveRecord::Base
def canonicalName(verbose=false)
	return "#{self.inspect}"
end #def
belongs_to :account
include Generic_Table
@@AREL=Arel::Table.new(:transfers)
def self.arel
	return @@AREL
end #def
def account_join
#	self.class.arel.includes(:accounts).where("accounts.open_tax_solver_line is not null")
end #def
def Transfer.open_tax_solver
	transfers = arel
	ots_data="Title:  US Federal 1040 Tax Form - 2010 - Generated\n\nStatus     Married/Joint {Single, Married/Joint, Head_of_House, Married/Sep, Widow(er)}\nDependents     2         {Number of Dependents, self=1, spouse, etc.}\n{Income}\n"
	#~ transfers.account_join.each do |transfer|
		#~ ots_data="#{ots_data} #{number_to_currency(transfer.amount).to_s}<BR>\n"
	#~ end # each
end #def
end

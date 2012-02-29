
###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'app/models/global.rb'
module GenericHtml
module ClassMethods
# column order for default html generation
def column_order
	ret=logical_primary_key
	ret+=column_symbols-logical_primary_key-[:id]
	return ret
end #column_order
def header_html(column_order=nil)
	if column_order.nil? then
		column_order=self.column_order
	end #if
	ret="<tr>"
	column_order.each do |header|
		ret+='<th>'+header.to_s.humanize+'</th>'
	end #each
	ret+="</tr>"
	return ret
end #header_html
# Produce default HTML for ActiveRecord model
def table_html(column_order=nil)
	if column_order.nil? then
		column_order=self.column_order
	end #if
	ret="<table>"
	ret+=header_html(column_order)
	self.all.each do |row|
		ret+=row.row_html(column_order)
	end #each
	ret+="</table>"
	return ret
end #table_html
end #GenericHtml::ClassMethods
# Calculate rails relative route to this record
def rails_route(action=nil)
	route=self.class.name.tableize+'/'+self[:id].to_s
	if action.nil? then
		return route
	else
		return route+'/'+action.to_s
	end #if
end #rails_route
def column_html(column_symbol)
	if self.class.foreign_key_names.map{|n|n.to_sym}.include?(column_symbol) then
		return link_to(self[column_symbol].to_s, foreign_key_to_association(column_symbol).rails_route)
	else
		return self[column_symbol].to_s
	end #if
end #column_html
def row_html(column_order=nil)
	if column_order.nil? then
		column_order=self.class.column_order
	end #if
	ret="<tr>"
	column_order.each do |col|
		ret+='<td>'+column_html(col)+'</td>'
	end #each
	ret+='<td>'+link_to('Show', rails_route)+'</td>'
    	ret+='<td>'+link_to('Edit', rails_route(:edit))+'</td>'
    	ret+='<td>'+link_to('Destroy', rails_route, :confirm => 'Are you sure?', :method => :delete)+'</td>'

	
	ret+="</tr>"
	return ret

end #row_html
end #GenericHtml

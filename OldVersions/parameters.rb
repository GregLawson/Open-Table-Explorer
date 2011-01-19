#   Copyright (C) 2009  Gregory Lawson
#  
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation; either version 2.1 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Lesser General Public License for more details.
# 
#   You should have received a copy of the GNU Lesser General Public License
#   along with this program; if not, a copy is available at
#   http://www.gnu.org/licenses/gpl-2.0.html
require 'table.rb'
class Parameters < Finite_Table
def initialize
	super('Parameters','parameter')
	addColumn('parameter','VARCHAR(255)') if not columnExists('parameter') 
	addColumn('import_type','VARCHAR(255)') if not columnExists('import_type')
	addColumn('value','string') if not columnExists('value')
	#addColumn('dependancy','string') if not columnExists('dependancy')
	addColumn('formula','VARCHAR(255)') if not columnExists('formula')
	addColumn('updated_at','timestamp with time zone') if not columnExists('updated_at')
	#addColumn('lhs','string') if not columnExists('lhs')
	#addColumn('rhs','string') if not columnExists('rhs')
end
def []=(parameter,newValue)
	if newValue.match(/^[a-zA-Z][a-zA-Z0-9_]+$/) then
		update_attribute(parameter,newValue)
		update_attribute(formula,nil)
		#update_attribute(lhs,nil)
		#update_attribute(rhs,nil)
	else
		update_attribute(formula,newValue)
		update_attribute(parameter,eval(newValue))
	end
	storeOrOverwrite
	eval

end
def [](parameter)
	find(parameter)
	getValue(parameter)
end
def propagate(formula)
	sql="SELECT parameter,formula FROM Parameters WHERE parameter LIKE \"%#{formula}%\""
	res=DB.execute(sql)
	puts "sql=#{sql}" if $VERBOSE
	res.each do |r|
		if !r['formula'].nil? and r['formula']!=''
			propagate(r['parameter'])
			update_attribute(parameter,eval(newValue))
			storeOrOverwrite
		end
	end
end
end
param=Parameters.new
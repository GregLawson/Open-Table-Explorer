#   Copyright (C) 2009  Gregory Lawson
#  
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2.1 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, a copy is available at
#   http://www.gnu.org/licenses/gpl-2.0.html
require 'pg'
#require 'active_record'
class DB
  @@conn = PGconn.connect("localhost", 5432, '', '', "energy_development", "greg", "paul")
		PG_DIAG_SEVERITY       ='S'[0]
		PG_DIAG_SQLSTATE       ='C'[0]
		PG_DIAG_MESSAGE_PRIMARY='M'[0]
		PG_DIAG_MESSAGE_DETAIL ='D'[0]
		PG_DIAG_MESSAGE_HINT   ='H'[0]
		PG_DIAG_STATEMENT_POSITION='P'[0]
		PG_DIAG_CONTEXT        ='W'[0]
		PG_DIAG_SOURCE_FILE    ='F'[0]
		PG_DIAG_SOURCE_LINE    ='L'[0]
		PG_DIAG_SOURCE_FUNCTION='R'[0]
def initialize
end
#def DB.execute(sql)
#	res  = @@conn.exec(sql)
#rescue PGError => e
#	puts sql
#	puts "PGError: " + e.to_s
#end
def DB.resultsCheck(res)
	if res.result_status > 2 then
		puts "res.result_status=#{res.result_status}"
		puts "res.res_status(res.result_status)=#{res.res_status(res.result_status)}"
		puts "res.result_error_message=#{res.result_error_message}"
		#puts "res.result_error_field(PG_DIAG_SEVERITY)=#{res.result_error_field(PG_DIAG_SEVERITY)}"
		#puts "res.result_error_field(PG_DIAG_SQLSTATE)=#{res.result_error_field(PG_DIAG_SQLSTATE)}"
		puts "res.result_error_field(PG_DIAG_MESSAGE_PRIMARY)=#{res.result_error_field(PG_DIAG_MESSAGE_PRIMARY)}"
		puts "res.result_error_field(PG_DIAG_MESSAGE_DETAIL)=#{res.result_error_field(PG_DIAG_MESSAGE_DETAIL)}"
		puts "res.result_error_field(PG_DIAG_MESSAGE_HINT)=#{res.result_error_field(PG_DIAG_MESSAGE_HINT)}"
		puts "res.result_error_field(PG_DIAG_STATEMENT_POSITION)=#{res.result_error_field(PG_DIAG_STATEMENT_POSITION)}"
		puts "res.result_error_field(PG_DIAG_INTERNAL_POSITION)=#{res.result_error_field(PG_DIAG_INTERNAL_POSITION)}"
		puts "res.result_error_field(PG_DIAG_INTERNAL_QUERY)=#{res.result_error_field(PG_DIAG_INTERNAL_QUERY)}"
		puts "res.result_error_field(PG_DIAG_CONTEXT)=#{res.result_error_field(PG_DIAG_CONTEXT)}"
		puts "res.result_error_field(PG_DIAG_SOURCE_FILE)=#{res.result_error_field(PG_DIAG_SOURCE_FILE)}"
		puts "res.result_error_field(PG_DIAG_SOURCE_LINE)=#{res.result_error_field(PG_DIAG_SOURCE_LINE)}"
		puts "res.result_error_field(PG_DIAG_SOURCE_FUNCTION)=#{res.result_error_field(PG_DIAG_SOURCE_FUNCTION)}"
	end
	#puts "res=#{res}"
	#puts "res.result_status=#{res.result_status}"
end
def DB.exceptionCheck(sql,acceptableErrorMatch,errorText)
	#puts "$!=#{$!}"
	if errorText.to_s.match(acceptableErrorMatch) then
		#silent error
		#puts "ignoring #{errorText.to_s}"
	else
		puts "not ignoring #{errorText.to_s}"
		puts "acceptableErrorMatch=#{acceptableErrorMatch}"
		puts "errorText.to_s.match(acceptableErrorMatch)=#{errorText.to_s.match(acceptableErrorMatch)}"
		puts sql
		puts "PGError: " + errorText.to_s
 	end
end
def DB.find_by_sql(sql,acceptableErrorMatch=/^$/)  # returns full results data structure except on error
	res  = @@conn.exec(sql)
	#resultsCheck(res)       # fix me!
	if res.result_status > 2 then        # this may never happen as exception will branch
		puts "res.result_status=#{res.result_status}"
		puts "res.res_status(res.result_status)=#{res.res_status(res.result_status)}"
		puts "res.result_error_message=#{res.result_error_message}"
		#puts "res.result_error_field(PG_DIAG_SEVERITY)=#{res.result_error_field(PG_DIAG_SEVERITY)}"
		#puts "res.result_error_field(PG_DIAG_SQLSTATE)=#{res.result_error_field(PG_DIAG_SQLSTATE)}"
		puts "res.result_error_field(PG_DIAG_MESSAGE_PRIMARY)=#{res.result_error_field(PG_DIAG_MESSAGE_PRIMARY)}"
		puts "res.result_error_field(PG_DIAG_MESSAGE_DETAIL)=#{res.result_error_field(PG_DIAG_MESSAGE_DETAIL)}"
		puts "res.result_error_field(PG_DIAG_MESSAGE_HINT)=#{res.result_error_field(PG_DIAG_MESSAGE_HINT)}"
		puts "res.result_error_field(PG_DIAG_STATEMENT_POSITION)=#{res.result_error_field(PG_DIAG_STATEMENT_POSITION)}"
		puts "res.result_error_field(PG_DIAG_INTERNAL_POSITION)=#{res.result_error_field(PG_DIAG_INTERNAL_POSITION)}"
		puts "res.result_error_field(PG_DIAG_INTERNAL_QUERY)=#{res.result_error_field(PG_DIAG_INTERNAL_QUERY)}"
		puts "res.result_error_field(PG_DIAG_CONTEXT)=#{res.result_error_field(PG_DIAG_CONTEXT)}"
		puts "res.result_error_field(PG_DIAG_SOURCE_FILE)=#{res.result_error_field(PG_DIAG_SOURCE_FILE)}"
		puts "res.result_error_field(PG_DIAG_SOURCE_LINE)=#{res.result_error_field(PG_DIAG_SOURCE_LINE)}"
		puts "res.result_error_field(PG_DIAG_SOURCE_FUNCTION)=#{res.result_error_field(PG_DIAG_SOURCE_FUNCTION)}"
	end
	#puts "res=#{res}"
	#puts "res.result_status=#{res.result_status}"
	return res
rescue PGError => errorText
	exceptionCheck(sql,acceptableErrorMatch,errorText)
	#puts "$!=#{$!}"
		res=PGresult.new    # how do I fill this in?
		#res.result_status=-1 # recovered error. Does it clash
end
def DB.execute(sql,acceptableErrorMatch=/^$/) # returns only error message
	res  = @@conn.exec(sql)
	#resultsCheck(res)
	if res.result_status > 2 then      # this may never happen as exception will branch
		puts "res.result_status=#{res.result_status}"
		puts "res.res_status(res.result_status)=#{res.res_status(res.result_status)}"
		puts "res.result_error_message=#{res.result_error_message}"
		#puts "res.result_error_field(PG_DIAG_SEVERITY)=#{res.result_error_field(PG_DIAG_SEVERITY)}"
		#puts "res.result_error_field(PG_DIAG_SQLSTATE)=#{res.result_error_field(PG_DIAG_SQLSTATE)}"
		puts "res.result_error_field(PG_DIAG_MESSAGE_PRIMARY)=#{res.result_error_field(PG_DIAG_MESSAGE_PRIMARY)}"
		puts "res.result_error_field(PG_DIAG_MESSAGE_DETAIL)=#{res.result_error_field(PG_DIAG_MESSAGE_DETAIL)}"
		puts "res.result_error_field(PG_DIAG_MESSAGE_HINT)=#{res.result_error_field(PG_DIAG_MESSAGE_HINT)}"
		puts "res.result_error_field(PG_DIAG_STATEMENT_POSITION)=#{res.result_error_field(PG_DIAG_STATEMENT_POSITION)}"
		puts "res.result_error_field(PG_DIAG_INTERNAL_POSITION)=#{res.result_error_field(PG_DIAG_INTERNAL_POSITION)}"
		puts "res.result_error_field(PG_DIAG_INTERNAL_QUERY)=#{res.result_error_field(PG_DIAG_INTERNAL_QUERY)}"
		puts "res.result_error_field(PG_DIAG_CONTEXT)=#{res.result_error_field(PG_DIAG_CONTEXT)}"
		puts "res.result_error_field(PG_DIAG_SOURCE_FILE)=#{res.result_error_field(PG_DIAG_SOURCE_FILE)}"
		puts "res.result_error_field(PG_DIAG_SOURCE_LINE)=#{res.result_error_field(PG_DIAG_SOURCE_LINE)}"
		puts "res.result_error_field(PG_DIAG_SOURCE_FUNCTION)=#{res.result_error_field(PG_DIAG_SOURCE_FUNCTION)}"
	end
	#puts "res=#{res}"
	#puts "res.result_status=#{res.result_status}"
	if res.result_status >2 then
		return res.res_status(res.result_status)
	else 
		return ""
	end
rescue PGError => errorText
	exceptionCheck(sql,acceptableErrorMatch,errorText)
	return errorText.to_s
end
end
 class RowsAndColumns
attr_reader :sqlNames, :sqlTypes ,:sqlValues, :data, :sqlUpdate
attr_writer :sqlValues, :data, :sqlUpdate
def initialize
	@sqlNames=[]
	@sqlTypes=[]
	@sqlValues=[]
	@sqlUpdate=[]
	@data={}
end
def update_attribute(name,value)
	if name.nil? then
		puts "name is nil in update_attribute."
	else
		#puts "name=#{name} value=#{value}"
		#dumpNames
		lookup=getIndex(name.downcase)
		if lookup.nil? then
			if   dontIgnore(name) then
				puts "#{name} is not in @sqlNames for table #{@table_name}."
				puts "@sqlNames=#{@sqlNames.join(',')}"
			end
		else
			#dumpAcquisitions
			#puts "name=#{name} value=#{value}"
			#puts "lookup=#{lookup}"
			#puts "@sqlTypes[#{lookup}]=#{@sqlTypes[lookup]}"
			@sqlValues[lookup]=@sqlTypes[lookup].new(value)
			#puts "@sqlValues[#{lookup}]=#{@sqlValues[lookup]}"
			#puts "@sqlValues[lookup].null= #{@sqlValues[lookup].null}@sqlValues[lookup].value= #{@sqlValues[lookup].value} #{@sqlValues[lookup].to_s}"
			#puts "name=#{name} value=#{value} @sqlValues[#{lookup}]=#{@sqlValues[lookup]} #{@sqlValues[lookup].null} #{@sqlValues[lookup].value} #{@sqlValues[lookup].to_s}"
			#dumpAcquisitions(FALSE)
		end
	end
end
def setIndexedValue(index,value)
	@sqlValues[index]=@sqlTypes[index].new(value)
end
def sqlForm(names)
	ret=[]
	names.each do |s| 
		s=Import_Column.unquote(s,'"')
		subs=s.strip.tr(",\s|\.|\n|\-",'_____')
		print "#{s}.sub=>#{subs}\n"  if $DEBUG
		ret.push(subs.downcase)
		end
	return ret
end
def  getIndex(name)
	nameIndex=@sqlNames.index(name.downcase)
	puts "name=#{name}" if $DEBUG
	puts "@sqlNames.index(name)=#{@sqlNames.index(name)}" if $DEBUG
	puts "nameIndex=#{nameIndex}" if $DEBUG
	if nameIndex.nil? then
		if   dontIgnore(name) then
			print "#{name} is not in " 
			print "\(#{@sqlNames.join(',')}\) for "  if $DEBUG
			puts "table #{@table_name}" 
		end
	end
	return  nameIndex
end
def getRetrieved(name)
	nameIndex=getIndex(name)
	return @retrievedValues[nameIndex]
end
def getValue(name)
	nameIndex=getIndex(name)
	return @sqlValues[nameIndex]
end
def values2hash (values)
	data={}
	@sqlNames.each_index do |i|
 		#puts "#{@sqlNames[i]} "
 		#puts "#{@sqlTypes[i]} "
 		#puts "\"#{values[i]}\" "
		if columnExists(@sqlNames[i]) then
			data[@sqlNames[i]]=values[i]
		else
			puts "#{@sqlNames[i]} not stored because column does not exist."
		end		
	end
	return data	
end
def dumpNameIndex(i)
	print "#{i} #{@sqlNames[i]} "
	print "#{@sqlTypes[i]} "
end
def dumpUpdateIndex(i)
	dumpNameIndex(i)
	print "\"#{@sqlUpdate[i]}\""
	print " #{@sqlUpdate[i].class} "
	if @sqlUpdate[i] != @retrievedValues[i] then
		print " was \"#{@retrievedValues[i]}\""
		print " #{@retrievedValues[i].class}"
	end
	print "\n "
end
def dump (values)
	@sqlNames.each_index do |i|
 		print "#{i} #{@sqlNames[i]} "
 		print "#{@sqlTypes[i]} "
 		print "\"#{values[i]}\"\n "
	end
end
def dumpNames
	#puts "@sqlNames.class=#{@sqlNames.class}"
	if @sqlNames.nil? then
		puts "No columns have been defined since initialization of table #{@table_name}."
	else
		if @sqlNames.length != @sqlTypes.length then
			puts "@sqlNames.length != @sqlTypes.length"
		end
		puts "@sqlNames.length=#{@sqlNames.length}"
		@sqlNames.each_index do |i|
			dumpNameIndex(i)
			print "\n "
		end
	end
end
def dumpUpdates
	@sqlNames.each_index do |i|
		dumpUpdateIndex(i)
 		print "\n "
	end
end
def dumpHash
	puts "#{@table_name} has #{@data.length} columns including:"
	@sqlNames.each_index do |i|
 		dumpNameIndex(i)
 		print "\"#{@data[@sqlNames[i]]}\""
 		print " #{@data[@sqlNames[i]].class}"
  		print "\n "
	end
end
def dumpAcquisitionIndex(i)
	dumpNameIndex(i)
	print "\"#{@sqlValues[i]}\""
	print " #{@sqlValues[i].class} "
	if @sqlValues[i].is_a?(Import_Column) then
		if @sqlValues[i].class != @sqlValues[i].value.class
			print " @sqlValues[i].value.class=#{@sqlValues[i].value.class} "
		end
	else
		print " not a Import_Column "
	end
	print " #{@sqlValues[i].to_s} "
	print "\n "
end
def dumpAcquisitions(detail=TRUE)
	puts "@sqlValues.class=#{@sqlValues.class}"
	if @sqlValues.nil? then
		puts "@sqlValues has not been initialized as an empty array during acquisition for table #{@table_name}."
	elsif @sqlValues.length==0 then
		puts "@sqlValues has not been assigned any value during acquisition for table #{@table_name}."
	else
		puts "@sqlValues.length=#{@sqlValues.length}"
		if detail then
			@sqlNames.each_index do |i|
				dumpAcquisitionIndex(i)
			end
		end
	end
end

def hash2values (hashValues)
	values=[]
	@sqlNames.each_index do |i|
 		#puts "#{@sqlNames[i]} #{@sqlTypes[i]} \"#{values[i]}\""
		if columnExists(@sqlNames[i]) then
			values[i]=hashValues[@sqlNames[i]]
		else
			puts "#{@sqlNames[i]} not stored because column does not exist."
		end		
	end
	return values	
end
end
class ActiveRecord  < RowsAndColumns
attr_reader :table_name,:row
def initialize(tableName,primaryKey)
	super()
	@table_name=tableName.downcase
	@primaryKey=primaryKey
	puts "@table_name=#{@table_name} table_exists?=#{table_exists?}" if $DEBUG
	if table_exists? then
		getNamesAndTypes
	else
		createTable
		getNamesAndTypes
	end
	if publicKeyChanged? then
		puts "publicKeyChanged?" if $VERBOSE
		updatePrimaryKey
	end
	#puts "@sqlTypes.class= #{@sqlTypes.class}" 
	@row=0 # start retrieval from first record
end
def save (acceptableErrorMatch=/^$/)
	dumpAcquisitions if $DEBUG
	names=[]
	valueStrings=[]	
	@sqlValues.each_index do |i| 
		if  !@sqlValues[i].nil? then
			puts "@sqlValues[18].class= #{@sqlValues[18].class} " if $DEBUG
			names.push(@sqlNames[i])
			dumpAcquisitionIndex(i)    if $DEBUG
			puts "@sqlValues[#{i}]=#{@sqlValues[i]} @sqlValues[#{i}].class=#{@sqlValues[i].class} @sqlValues[#{i}].value.class=#{@sqlValues[i].value.class}" if $DEBUG
			v=@sqlTypes[i].new(@sqlValues[i])
			puts "v=#{v}"  if $DEBUG
			p=v.to_postgresql
			puts "p=#{p}"     if $DEBUG
			valueStrings.push(p)
		end
	end
	sql= "INSERT INTO #{@table_name} (#{names.join(',')}) VALUES (#{valueStrings.join(',')});"
	#puts sql
	errorMessage  = DB.execute(sql,acceptableErrorMatch)
	if   errorMessage == '' then
		@sqlValues=[]
	end
	return errorMessage
end
def find(order,where="")
	#puts "@sqlTypes.class= #{@sqlTypes.class}" 
	if where!="" then 
		where ="WHERE #{where}"	
	end
	
	loop do
		sql="select * from #{@table_name} #{where} order BY #{order} LIMIT 1 OFFSET #{@row}"
		puts "sql=#{sql}"  if $VERBOSE
		@row=@row+1	
		res  = DB.find_by_sql(sql)
		if res.num_tuples>0 then
			@row=@row+1	
			for i in 0..res.nfields()-1 do
				puts "@sqlNames[#{i}]]=\"#{@sqlNames[i]}\"" if $VERBOSE
				#puts "@sqlTypes[#{i}]= #{@sqlTypes[i]}" 
				puts "res[0][@sqlNames[#{i}]]=\"#{res[0][@sqlNames[i].downcase]}\""    if $VERBOSE
				@sqlUpdate.push(@sqlTypes[i].new(res[0][@sqlNames[i].downcase]))
				#puts "@sqlUpdate.last=\"#{@sqlUpdate.last}\""
				#puts "@sqlUpdate.last.class_name=\"#{@sqlUpdate.last.class_name}\""
				#puts "@sqlUpdate.last.to_s=\"#{@sqlUpdate.last.to_s}\""
				#puts "@sqlTypes[i].class_name= #{@sqlTypes[i].class_name}" 
				#puts "#{@sqlNames[i]} #{@sqlTypes[i].class_name} \"#{@sqlUpdate[i]}\" #{@sqlTypeNum[i]}" 
		
			end
			#puts "res.num_tuples=#{res.num_tuples}"	
			#puts "res.fieldname(1)=#{res.fieldname(1)}"	
			#puts "res.class_name=#{res.class_name}"
			@retrievedValues=@sqlUpdate # save to detect changes
			break
		elsif @row==0 then
			puts "Danger of infnite loop. as relation is empty. sleep 60."
			sleep 60
		else
			@row=0
		end
	end
	
  	@sqlUpdate=[]
	#puts "@sqlTypes.class= #{@sqlTypes.class}" 
	#puts "@sqlTypes.length= #{@sqlTypes.length}" 
	#puts "@sqlTypes= #{@sqlTypes}" 
end
def table_exists?
	if @table_name.nil? then
		puts "table_exists? called with nil table name"
		return false
	end
	sql="select table_name from information_schema.tables where table_schema='public' AND table_name='#{@table_name}';"
	puts "sql=#{sql}"  if $DEBUG
	res  = DB.find_by_sql(sql)
	return res.num_tuples>0
end
end
class Table  < ActiveRecord
def tryAddPrimaryKey(pkeyName)
	sql="alter table #{@table_name} add primary key (#{@primaryKey})"
	acceptableError="NOTICE:  ALTER TABLE / ADD PRIMARY KEY will create implicit index \"#{pkeyName}\" for table \"#{@table_name}\""
	errorMessage=DB.execute(sql,acceptableError)
	#puts "tryAddPrimaryKey status=#{status}"
	return errorMessage
end
def updatePrimaryKey
	pkeyName="#{@table_name}_pkey"
	if publicKeyExists? then
		sql="alter table #{@table_name} DROP CONSTRAINT #{pkeyName}"
		acceptableError="ERROR:  constraint \"#{pkeyName}\" does not exist"
		errorMessage=DB.execute(sql,acceptableError)
		#puts "after DROP CONSTRAINT  status=#{status}"
	end
	errorMessage=tryAddPrimaryKey(pkeyName)
	puts " after tryAddPrimaryKey errorMessage=#{errorMessage}"
	needDistinct=  "ERROR:  could not create unique index \"#{pkeyName}\"\nDETAIL:  Table contains duplicated values.\n"
	#puts "status.length=#{status.length}"
	#puts "needDistinct.length=#{needDistinct.length}"
	if errorMessage == needDistinct then
		sql="CREATE table #{@table_name}_BACKUP AS SELECT DISTINCT * FROM #{@table_name}"
		errorMessage=DB.execute(sql)
		puts " after CREATE table errorMessage=#{errorMessage}"
		sql="TRUNCATE table #{@table_name}"
		errorMessage=DB.execute(sql)
		errorMessage=DB.execute("INSERT INTO #{@table_name}(#{@primaryKey}) SELECT DISTINCT #{@primaryKey}  FROM #{@table_name}_BACKUP")
		puts "INSERT INTO #{@table_name}(#{@primaryKey}) SELECT DISTINCT #{@primaryKey}  FROM #{@table_name}_BACKUP"
		puts " after INSERT INTO errorMessage=#{errorMessage}"
		sql="UPDATE  #{@table_name} SET (#{@table_name}.#{@sqlNames.join(",#{@table_name}.")})= (#{@table_name}_Backup.#{@sqlNames.join(",#{@table_name}_Backup.")}) FROM #{@table_name}_BACKUP WHERE #{@table_name}.#{@primaryKey}=#{@table_name}_BACKUP.#{@primaryKey}"
		puts "sql=#{sql}"
		errorMessage=DB.execute(sql)
		#errorMessage=DB.execute("DROP TABLE #{@table_name}_BACKUP")
		puts " after DROP TABLE errorMessage=#{errorMessage}"
		errorMessage=tryAddPrimaryKey(pkeyName)
	end
	return errorMessage
end
def createTable
	sql="CREATE TABLE #{@table_name} ()"
	errorMessage=DB.execute(sql)
	return errorMessage
end
def addColumn(name,type)
	sql="ALTER TABLE  #{@table_name} ADD COLUMN #{name.downcase} #{type};"
	errorMessage=DB.execute(sql)
	return errorMessage
end
def requireColumn(name,type)
	if columnExists(name) then
		return ""
	else
		puts "Column #{name} to be created with #{type}" if $VERBOSE
		return addColumn(name,type)
	end
end
def dontIgnore(column)
	return true # default to report everything
end
def columnExists(attrName)
	if attrName.nil? then
		puts "columnExists called with nil column name"
		return false
	end
	sql="select column_name from information_schema.columns where table_schema='public' and column_name='#{attrName.downcase}' AND table_name='#{@table_name}';"
	puts "sql=#{sql}"  if $DEBUG
	#sql="select * from pg_catalog.pg_attribute where attname='#{attrName.downcase}'"	
	res  = DB.find_by_sql(sql)
	if res.num_tuples==0 && dontIgnore(attrName) then	
		puts "#{attrName} has no column definition" if $VERBOSE
	elsif res.num_tuples>=2 then
		puts "#{attrName} has #{res.num_tuples} column definitions"
	else
		# expected response
	end
	#puts res.inspect
	#puts res.status
	return res.num_tuples>0
end
def publicKeyChanged?   # will not detect reordering of columns because of limitations of information_schema.constraint_column_usage
	sql="select column_name from information_schema.constraint_column_usage where table_schema='public' AND table_name='#{@table_name}' AND constraint_name='#{@table_name}_pkey';"
	puts "sql=#{sql}"      if $DEBUG
	res  = DB.find_by_sql(sql)
	publicKeyColumns=[]
	for i in 0..res.num_tuples-1 do
		publicKeyColumns.push(res[i]['column_name'])
	end
	publicKeyColumns.sort!
	pkeyColumns=@primaryKey.split(',').sort
	if $VERBOSE and publicKeyColumns!=pkeyColumns then
		puts "Public key was '#{publicKeyColumns.join(',')}'"
		puts "Want to change to '#{@primaryKey}'"
		if @primaryKey !=  pkeyColumns then
			puts "New pkey sorted '#{pkeyColumns}'"
		end
	end
	return publicKeyColumns!=pkeyColumns
end
def publicKeyExists?   # will not detect reordering of columns because of limitations of information_schema.constraint_column_usage
	sql="select column_name from information_schema.constraint_column_usage where table_schema='public' AND table_name='#{@table_name}';"
	#puts "sql=#{sql}"
	res  = DB.find_by_sql(sql)
	return res.num_tuples>0
end
def getNamesAndTypes
	sql="SELECT column_name, import_type FROM importTypes WHERE table_name='#{@table_name}';"
	res  = DB.find_by_sql(sql)
	for i in 0..res.num_tuples-1 do
		@sqlNames.push(res[i]['column_name'].downcase)
		@sqlTypes.push(Import_Column.string2ImportType(res[i]['import_type']))
		#puts "@sqlTypes.last=\"#{@sqlTypes.last}\""
	end
	#puts "@sqlTypes.class= #{@sqlTypes.class}" 
	#dumpNames
end
def nameEquations(names)
	puts names.join(',') if $DEBUG
	equations=[]
	names.each do |c|
		v= getValue(c)
		if !v.nil? then
			equations.push("#{c}=#{v.to_postgresql}")
		end
	end
	puts equations.join(',') if $VERBOSE
	return  equations
end
def update
	if @retrievedValues!=@sqlUpdate then		
		assignments=[]
		@retrievedValues.each_index do |i|
			if @sqlUpdate[i]!=@retrievedValues[i] then
				assignments.push(@sqlNames[i])
			end
			#puts "@selection[#{i}]=#{@selection[i]}"
		end
			
		sql= "UPDATE #{@table_name} SET #{nameEquations(assignments).join(",")} WHERE #{nameEquations(@primaryKey.split(',')).join(' AND ')};"
		puts sql if $VERBOSE
		errorMessage  = DB.execute(sql)
	end	
	return errorMessage
end
def overwrite
	assignments=nameEquations(@sqlNames-@primaryKey.split(','))
	if assignments.empty? then
		return ""
	else
		sql= "UPDATE #{@table_name} SET #{assignments.join(",")} WHERE #{nameEquations(@primaryKey.split(',')).join(' AND ')};"
		#puts sql
		errorMessage  = DB.execute(sql)
		if   errorMessage == '' then
			@sqlValues=[]
		end
		return errorMessage
	end
end
def storeOrOverwrite
	existsMsg = "ERROR:  duplicate key value violates unique constraint \"#{@table_name}_pkey\"\n"
	errorMessage=save(existsMsg)
	#puts "errorMessage='#{errorMessage}'"
	#puts "existsMsg   ='#{existsMsg}'"
	#puts "errorMessage.length=#{errorMessage.length}"
	#puts "existsMsg.length   =#{existsMsg.length}"
	#puts "errorMessage == existsMsg   =#{errorMessage == existsMsg}"
	if errorMessage == existsMsg then
		#puts "try overwrite"
		overwrite
	end
end
def compute # generic tables have no known computations
end
def recalculate(timeSlice,where)
	start=Time.now
	until Time.now> start+timeSlice
		find(@primaryKey,where)
		@data=values2hash(@sqlUpdate)
		#puts "in recalclate, data=#{@data}"
		compute
		#puts "in recalculate"
		@sqlUpdate=hash2values(@data)
		update
	end
end
end
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
require 'strscan'
require 'pp'
require 'ipaddr'
class Import_Column
attr_reader :value, :null
# first column - rails_type
# Second column - column type
# Third column - recognition pattern. First match is used. inet, float and integr overlap. 
# For a column use max type as column type; it will be the more general category.
# Specific matches should be first. Broader categories should come later
def  Import_Column.firstMatch(importString)
	return Generic_Types.all[0] if importString.nil?
	importString.strip! # removes leading and trailing white space f any (probably only in string regexps)
	Generic_Types.all.each do |typeRecord|
		puts "typeRecord.inspect=#{typeRecord.inspect}" if $VERBOSE
		Global::log.debug("typeRecord.import_class=#{typeRecord.import_class}")
		@matchPos=(importString =~ typeRecord.data_regexp )
		if @matchPos == 0 then
			return typeRecord
			#break # stop at first match
		end
	end
	raise RuntimeError "no pattern matches"		
end
def Import_Column.railsType(typeRecord)
	return  typeRecord.rails_type
end
def Import_Column.row2ImportType(typeRecord)
	return typeRecord.import_class
end
def  Import_Column.string2ImportType(typeName)
	return eval(typeName)
end
def set(value)
	Global::log.debug("set value=#{value}, class=#{value.class} value.ancestors.join(',')=#{value.class.ancestors.join(',')}")
	if value.nil? then
		@null=true
		@value="NULL"
	elsif value==""
		@null=true
		@value="NULL"
	else
		@null=false
		Global::log.debug("set calling typedSet value=#{value}, class=#{value.class} value.ancestors.join(',')=#{value.class.ancestors.join(',')}")
		typedSet(value)
	end
end
def nil?
	if @null then
		return true
	elsif value.nil? then
		return true
	elsif value==""
		return true
	else
		return false
	end

end
def typedSet(value)
	Global::log.debug("typedSet value=#{value}, class=#{value.class}")
 	Global::log.debug("value.ancestors.join(',')=#{value.class.ancestors.join(',')}")
	if value.is_a?(Import_Column) then
		@value=value.value
		Global::log.debug("value.is_a?(Import_Column)")
	elsif value.class=="String" then
		@value=value
		Global::log.debug("@value=#{@value}")
		Import_Column.unquote(@value,"'")
		Global::log.debug("@value=#{@value}")
	elsif value.class=="REXML::Text" then
		@value=value.to_s
	else
		
		str=value# variable used in expressions
		typeRecord=Generic_Types.find(:first,:conditions => { :import_class => self.class.name })
		@value=eval(typeRecord.ruby_conversion)
		Global::log.debug("else @value=#{@value}")
        end
	Global::log.debug("@value=#{@value} @value.class=#{@value.class}")
end
def initialize(value)
	Global::log.debug("initialize value=#{value}, class=#{value.class} value.ancestors.join(',')=#{value.class.ancestors.join(',')}")
	set(value)
end
def to_postgresql
	Global::log.debug("to_postgresql @value=#{@value} @value.class=#{@value.class}")
	if nil? then
		return "NULL"
	else
		return to_postgresql_notNull
	end
end
def to_postgresql_notNull
	return @value.to_s
end
def to_s
	if @null then
		return "NULL"
	else
		return to_notNull.to_s
	end
end
def to_notNull
	return @value
end


end

class NULL_Column < Import_Column # no data in column so type can't be determined
def NULL_Column.class_name
	return "VARCHAR(255)"
end
def to_postgresql_notNull
	return "NULL"
end
end
class Boolean_Column < Import_Column
def Boolean_Column.class_name
	return "boolean"
end
def to_postgresql_notNull
	if @value == "t" then
		return "TRUE"
	elsif @value == "f" then
		return "FALSE"
	else
		return @value
	end
end
def []=(rvalue)
	@value=rvalue
end
end
class Integer_Column < Import_Column
#def initialize(strValue)
#	if strValue.nil? then
#		@null=true
#		@value="NULL"
#	elsif strValue==""
#		@null=true
#		@value="NULL"
#	else
#		@null=false
#		@value=strValue.to_i
#	end
#end
def Integer_Column.class_name
	return "integer"
end
def to_i
	return @value.to_i
end
end
class Named_Type  < Import_Column
def to_postgresql_notNull
	return "#{self.class.class_name} '#{value}'"
end
end
class Inet_Column < Named_Type
def Inet_Column.class_name
	return "inet"
end
end
class Macaddr_Column < Named_Type
def Macaddr_Column.class_name
	return "macaddr"
end
end

class Time_Column < Named_Type
def Time_Column.class_name
	return "time"
end
def to_s
	return value.strftime('%X')
end
# def typedSet(value)
# 	puts "Time_Column.typedSet"  #if $DEBUG
# 	if value.class=='string' then
# 		@value=Import_Column.unquote(value,"'")
# 		Global::log.debug("string")
# 	elsif  value.is_a?(Import_Column)
# 		@value=value.value
# 		Global::log.debug("Import_Column")
# 	else
# 		@value=value
# 		Global::log.debug("else")
# 	end
# end
def to_postgresql_notNull
	return "Time '#{@value.strftime("%H:%M:%S %Z")}'"
end
end
class Timestamp_Column < Named_Type
def Timestamp_Column.class_name
	return "timestamp"
end
def to_s
	return value.rfc2822
end
# def typedSet(value)
# 	puts "Timestamp_Column.typedSet"   #if $DEBUG
# 	if value.class=='string' then
# 		@value=Time.new(value)
# 		Global::log.debug("string")
# 	elsif  value.is_a?(Import_Column)
# 		@value=value.value
# 		Global::log.debug("Import_Column")
# 	else
# 		@value=value
# 		Global::log.debug("else")
# 	end
# end
def to_postgresql_notNull
	Global::log.debug("@value=#{@value} @value.class=#{@value.class}")
	return "Timestamp '#{@value.strftime("%a %b %d %H:%M:%S %Z %Y")}'"
end
end
class Float_Column < Import_Column
def Float_Column.class_name
	return "real" # single precision (float gives double precision by default)
end
def to_f
	return @value.to_f
end
def to_notNull
	#print "VARCHAR_Column.to_s called.\n"
	return @value.to_f
end
end
class VARCHAR_Column < Import_Column
def VARCHAR_Column.class_name
	return "VARCHAR(255)"
end
def to_postgresql_notNull
	#print "VARCHAR_Column.to_s called.\n"
	return "\'#{@value}\'"
end
end
class Text_Column < Import_Column
def Text_Column.class_name
	return "text"
end
def to_postgresql_notNull
	#print "VARCHAR_Column.to_s called.\n"
	return "\'#{@value}\'"
end
end
class VerboseStringScanner <  StringScanner
def after(labelPattern,valuePattern)
	label=scan(labelPattern)
	if label.nil? then
		puts "Label /#{labelPattern}/ not found in '#{rest}'."
		return nil
	else # label found
		#puts "Found #{matched}."
		ret=scan(valuePattern)
		if ret.nil? then
			puts "Value /#{valuePattern}/ not found in '#{rest}'."
			return nil
		else
			#puts "Found #{matched}."
			#puts "ret=#{ret}"
			return ret
		end
	end
	
end
end
require 'generic.rb'
class Generic_Columns  < ActiveRecord::Base
def Generic_Columns.Column_Definitions
	return [
	['model_class','string'],
	['Column_Name','string'],
	['Before_Pattern','string'],
	['data_type','string'],
	['After_Pattern','string']
	]
end
end
class Generic_Types  < ActiveRecord::Base
def self.all
	externalStrings=find(:all,:order => "search_sequence ASC") # all records from Actve Record
	# return with strings converted to ruby types
	ret=externalStrings.collect do |t| # for each type t
		t.import_class=eval(t.import_class)
#		t.rails_type=eval(t.rails_type)
		t.data_regexp=Regexp.new("^#{t.data_regexp}$")
		t # returns tppe record to collect
	end
	return ret
end

end # class
class Example_Types  < ActiveRecord::Base
def self.all
	externalStrings=find(:all,:order => "import_class ASC") # all records from Actve Record
	# return with strings converted to ruby types
	ret=externalStrings.collect do |t| # for each type t
		Global::log.debug("t.inspect=#{t.inspect}")
		t.import_class=eval(t.import_class)
		Global::log.debug("t.inspect=#{t.inspect}")
		t # returns to collect
	end
	Global::log.debug("ret.inspect=#{ret.inspect}")
	return ret
end
end
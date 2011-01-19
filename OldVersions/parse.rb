###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'ModTest.rb'
require "rubygems"
module Generic_Parse
 mixin_class_methods { |klass|
 puts "Module Acquisition has been included by #{klass}" if $VERBOSE
 }
define_class_methods {

def unquote(value,quote)
	s=StringScanner.new(value)
	quoteRegexp= Regexp.new(quote)
	if s.skip(quoteRegexp) then
		return s.scan_until(quoteRegexp).chop.gsub('\'',"''")
	else
		return value.gsub('\'',"''")
	end
end #def
def sqlForm(s)
	s=unquote(s,'"')
	subs=s.strip.tr(",\s|\.|\n|\-",'_____')
	subs.sub!('_blank_','_')  # Sunny Web Box needs this
	subs.sub!(/_$/,'')  # Sunny Web Box needs this for missing units
	print "#{s}.sub=>#{subs}\n"  if $DEBUG
	return subs.downcase
end
def parse(dataToParse,selection='',parseTreeClass=getParseTreeClass)
#def parse(dataToParse,selection='')
	if selection.nil? ||selection.empty? then
		return dataToParse
	elsif dataToParse.instance_of?(String) then
		@parsedData= parseTree(dataToParse).search(selection)
	elsif dataToParse.instance_of?(parseTreeClass) then
		@parsedData= dataToParse.search(selection)
	else
		puts "dataToParse of type #{dataToParse.class} not of expected type=#{dataToParse}."
		puts "dataToParse.inspect=#{dataToParse.inspect}"
	end
	return @parsedData
end #def
def getParseTreeClass
	# cache value of type of parse tree.
	if @getParseTreeClass.nil? then
		@getParseTreeClass=parseTree('','').class
	end #if
	return @getParseTreeClass
end #def
def parseHeader(dataToParse,column_name_selection)
	nameRow=parseTree(dataToParse,column_name_selection)
#	puts "nameRow.size=#{nameRow.size}"
	names=nameRow.collect do |column|
		puts "column.inspect=#{column.inspect}" if $DEBUG
		extract_import_text(column)
	end
	return names
end #def
} #class methods
end # module
# module Regexp_Parse
#  mixin_class_methods { |klass|
#  puts "Module Regexp_Parse has been included by #{klass}" if $VERBOSE
#  }
# include Generic_Parse
# define_class_methods {
# def parseTree(dataToParse,selection='.*')
# 	parser= Regexp.new(selection)
# 	return parser.match(dataToParse)
# end #def
# } #class methods
# end #module
module XML_Parse
 mixin_class_methods { |klass|
 puts "Module XML_Parse has been included by #{klass}" if $VERBOSE
 }
include Generic_Parse
define_class_methods {
def parseTree(dataToParse,selection='*/*')
	@parsedData= REXML::Document.new(dataToParse)
	return @parsedData.get_elements(selection)
end #def
def parseOld(dataToParse,treePattern='*/*')
#	@row=self.new
	@parsedData= REXML::Document.new(dataToParse)
	variableHash=Hash.new
	@parsedData.elements.each(treePattern) do |s|
		puts "s=#{s}" if $DEBUG
		attrName=s.name.to_s
		puts "attrName=#{attrName}" if $DEBUG
		puts "s[0].to_s=#{s[0].to_s} s[0].to_s.class=#{s[0].to_s.class}"  if $DEBUG
		variableHash[attrName]=s[0].to_s
	end
	return variableHash
end
def extract_import_text(dataToParse)
#	may prefer text() for multiple chldren (as array)
	return dataToParse.texts.join(';') # http://ruby-doc.org/core/classes/REXML/Element.html#M005626

end #def
} # class methods

end #module
module Generic_Parse
 mixin_class_methods { |klass|
 puts "Module Generic_Parse has been included by #{klass}" if $VERBOSE
 }
define_class_methods {

} #define_class_methods
end #module
require "hpricot"
module HTML_Parse
 mixin_class_methods { |klass|
 puts "Module HTML_Parse has been included by #{klass}" if $VERBOSE
 }
include Generic_Parse
define_class_methods {
def parseTree(dataToParse,selection='*/*')
	return @parsedData= Hpricot(dataToParse).search(selection)
end #def
def parseOld(dataToParse,treewalk)
# 	treewalk="html>body>table>tr>td:nth-child(6)"
# 	treewalk="html>body>table>tr>(td.xl83 ~ td.xl37)"
# 	treewalk="html>body>table>tr>td.xl35~td[@class^=\"xl3\"]"
	@parsedData= Hpricot(dataToParse).search(treewalk)
	variableHash=Hash.new
	@parsedData.each do |s|
		puts "s.inner_html=#{s.inner_html}" if $DEBUG
# 		attrName=s.name.to_s
# 		puts "attrName=#{attrName}" if $DEBUG
# 		puts "s[0].to_s=#{s[0].to_s} s[0].to_s.class=#{s[0].to_s.class}"  if $DEBUG
# 		variableHash[attrName]=s[0].to_s
	end
	return variableHash
end #def
def extract_import_text(dataToParse)
	return dataToParse.inner_html
end #def
} #define_class_methods
end #module
module CSV_Parse
include Generic_Parse
end #module
module JSON_Parse
 mixin_class_methods { |klass|
 puts "Module Acquisition has been included by #{klass}" if $VERBOSE
 }
include Generic_Parse
define_class_methods {
def alterColumns(defs=self.column_Definitions)
	defs.each {|c| puts "alter table #{name} add column #{c[0]} #{c[1]}" }
end
def parseTree(dataToParse,selection='*/*CurrentValues')
	result = JSON.parse(dataToParse)
	cv=result[selection]
end #def
def parseOld(dataToParse,treewalk)
	puts "dataToParse=#{dataToParse}" if $DEBUG
	#puts "TEDWebBoxFull.dataToParse=#{TEDWebBoxFull.dataToParse}"

	result = JSON.parse(dataToParse)
	cv=result['CurrentValues']
	#Class.whoAmI(row)
	#puts "row.inspect=#{row.inspect}"
	variableHash=Hash.new
	cv.each do |j|
		name=sqlForm("#{j['Name']}_#{j['Unit']}")
		variableHash[name]= j['Value']
	end #each
	return variableHash
end

} # define_class_methods
end # module

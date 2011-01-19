#!/usr/bin/ruby
#   Copyright (C) 2009,2010  Gregory Lawson
#  
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation; either version 2.1 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU Lesser General Public License
#   along with this program; if not, a copy is available at
#   http://www.gnu.org/licenses/gpl-2.0.html
#require 'table.rb'
require 'ModTest.rb'
require "rubygems"
require 'r.rb'
require 'strscan'
require 'acquire.rb'
require 'parse.rb'
require 'inlineAssertions.rb'
class Parse_Classes
include Inline_Assertions
attr_reader :model_class, :parse_interface, :classRef, :URLS, :ParseTypeRecords, :acquisitionData

def Parse_Classes.parse_classes(model_class_name)
	acs = Generic_Acquisitions.all(:conditions =>{:model_class=>model_class_name}, :select => 'model_class,acquisition_interface,parse_interface', :group => 'model_class,acquisition_interface,parse_interface') 
	ret = acs.collect do |ac|
		Parse_Classes.new(model_class_name,ac.parse_interface)
	end #collect
	return ret
end #def


def Parse_Classes.classDefinition(model_class, parse_interface)
	Global::log.debug("self.inspect=#{self.inspect}")
	classDef="class #{parse_interface}
		include #{parse_interface}
		end # module
		"
	return classDef
end #def
def Parse_Classes.class_Reference(model_class, acquisition_interface, parse_interface)
	evalString="#{classDefinition(model_class, acquisition_interface, parse_interface)}\n#{acquisition_interface}_#{parse_interface}"
	return eval(evalString) # keep activeRecord from prefixing nested classes.
end #def
def initialize(model_class,parse_interface)
	@model_class=model_class
	@model_class_eval=MODEL_REFS[model_class]
	@parse_interface=parse_interface
	@classDef=Parse_Classes.classDefinition(model_class, parse_interface)
	Global::log.debug("classDef=#{@classDef}")
	eval(@classDef)
	@classRef=Parse_Classes.class_Reference(model_class, acquisition_interface, parse_interface)
	Global::log.debug("@classRef=#{@classRef}")
	@ParseTypeRecords=Generic_Acquisitions.parseTypeRecords(self)
	@URLS=@ParseTypeRecords.keys.uniq
	@acquisitionData={}
	@TYPE_RECORDS=Generic_Acquisitions.all(:conditions =>{:model_class=>model_class})
	@ACQUISITIONS=@TYPE_RECORDS.collect do |a|
		Hash.new(:url => a.url,:acquisition_interface => a.acquisition_interface)
	end #collect
	return @ACQUISITIONS.uniq
end #def
def acquire
	ads=@URLS.collect do |url|
		ad=@classRef.acquire(url)
		assert_instance_of(Array,ad)
		assert_instance_of(String,ad[0])
		assert_instance_of(String,ad[1])
		@acquisitionData[url]=ad
		Global::log.debug("ad.inspect=#{ad.inspect}")
		ad
	end #each
	Global::log.info("at end of acquire acquisitionData.inspect=#{acquisitionData.inspect}")
	return ads
end #def
def acquisitionsUpdated?
	acquisitionsUpdated=@URLS.any? do |url|
		ad=@classRef.acquisitionUpdated?
		ad
	end #each
	Global::log.info("at end of acquisitionsUpdated? acquisitionsUpdated.inspect=#{acquisitionsUpdated.inspect}")
	return acquisitionsUpdated
end #def
def extractTable(acquisitionData)
	if table_selection.empty? then
		return acquisitionData
	elsif table_selection_is_regexp then
		matchData=table_selection.match(acquisitionData)
		eval("matchData#{treewalk}")
	else
	end #if
end #def
def parse(acquisitionData,treewalk)
	@parseTree=parse(@extractedTable)
	rows=@parseTree.collect(treewalk) do |e|
		row=eval("e#{treewalk}")
		columns=row.each do |c|
		end # each c
	end #each
end #def
def parse
	Global::log.info("acquisitionData.inspect=#{@acquisitionData.inspect}")
	parses=@URLS.collect do |url|
		@ParseTypeRecords[url].collect do |p|
			if @classRef.acquisitionUpdated?(@acquisitionData[url]) then
			@extractedTable=extractTable(@acquisitionData[url])
			variableHash=@classRef.parse(@extractedTable,p.tree_walk)
			Global::log.info("variableHash.inspect=#{variableHash.inspect}")
			if p.name_prefix.nil? then
			elsif !p.name_prefix.empty? then
				variableHash=@classRef.addPrefix(variableHash,p.name_prefix.downcase)
				Global::log.info("variableHash.inspect=#{variableHash.inspect}")
	
			end	
			variableHash=onlyInModel(variableHash)
			Global::log.info("variableHash.inspect=#{variableHash.inspect}")
			variableHash
			end #if
		end #collect
	parses
	end #each_index
end #def
def onlyInModel(variableHash)
	ret=Hash.new
	variableHash.each_pair do |key,value|
		if @model_class_eval.column_names.include?(key) then
			ret[key]=value
		else
			Global::log.debug("#{key} not in model.") if $DEBUG
		end
	end
	return ret
end #def
end #class
require 'ga.rb'

#!/usr/bin/ruby
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
#require 'table.rb'
require 'generic.rb'
#require 'activeRecordDB.rb'
require 'columns.rb'
#require 'ipaddr'
#class Networks < Finite_Table 
class Networks  < ActiveRecord::Base
include Shell_Acquisition
def initialize
	super('Networks')
	#super('Networks','nmap_addresses')          n
	requireColumn('nmap_addresses','string')
	requireColumn('last_scan','timestamp with time zone')
	requireColumn('nmap_execution_time','float')
	requireColumn('expanded','boolean')
	#@hosts=Hosts.new
end
def self.whereAmI
	ifconfig=`/sbin/ifconfig|grep "inet addr" `
	#puts ifconfig
	s = VerboseStringScanner.new(ifconfig)
	@myContext=s.after(/\s*inet addr:/,/[0-9]*\.[0-9]*\./)
	@myNetwork=s.scan(/[0-9]+\./)
	@myNode=s.scan(/[0-9]+/)
	#puts "@myContext=#{@myContext}"
	#puts "@myNetwork=#{@myNetwork}"
	#puts "@myNode=#{@myNode}"
	@myIP="#{@myContext}#{@myNetwork}#{@myNode}"
	#puts "@myIP=#{@myIP}"
	#ip=IPAddr.new(@myIP)
	#puts "ip=#{ip}"
	@myNetmask=s.after(/.*\sMask:/,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)
	#puts "@myNetmask=#{@myNetmask}"
	#ip=ip.mask(@myNetmask)
	#puts "ip=#{ip}"
	#puts "masklen(\"cidr #{@myNetmask}\")"
	#@hosts=Hosts.new
	Hosts.recordDetection(@myIP)
	@nmapScan="#{@myContext}#{@myNetwork}1-254"
	network=find_or_initialize_by_nmap_addresses(@nmapScan)
	network.update_attribute('nmap_addresses',@nmapScan)
	network.dumpAcquisitions if $DEBUG
	network.save
	end
def self.acquire
	self.whereAmI
# now do incremental ping and nmapScan
	Global::log.debug("networks before find @row=#{@row}")
	network=Networks.first(:order => 'last_scan ASC')
	puts "nmap_addresses=#{network.nmap_addresses}"  if $VERBOSE
	Networks.ping(network.nmap_addresses)
	host=Hosts.first(:order => 'last_detection ASC')
	Hosts.nmapScan(host.ip)
end
def self.ping(nmapScan)
	network=Networks.find_or_initialize_by_nmap_addresses(nmapScan)
	puts "nmap -sP #{nmapScan}"     #if $VERBOSE
	@pingNmap=`nmap -sP #{nmapScan}`
	Global::log.debug("@pingNmap=#{@pingNmap}")
	network.update_attribute('last_scan',Time.new)
	network.save
	@pingNmap.each_line do |r|
		Global::log.debug("Line: '#{r}'")
		s = VerboseStringScanner.new(r)
		if s.scan(/Host /) then
			matchData=/[0-9.]{1,3}\.[0-9.]{1,3}\.[0-9.]{1,3}\.[0-9.]{1,3}/.match(r)
			candidateIP= matchData[0]
			Hosts.recordDetection(candidateIP)
			Global::log.debug("candidateIP=#{candidateIP}")
		elsif  s.scan(/Nmap done:/)
			up,nmap_execution_time=Hosts.scanNmapSummary(s)
			network.update_attribute('nmap_execution_time', nmap_execution_time)
			puts "nmap_execution_time=#{nmap_execution_time}" #if $VERBOSE
		elsif s.scan(/^\s*$|Starting Nmap/)   then
			# ignore line
		else
			puts "Line not decoded: '#{r}'"
		end
	end
	#network.dumpAcquisitions if $VERBOSE
	network.inspect if $VERBOSE
	network.save
end
end
class Ports  < ActiveRecord::Base   # class Hosts populates ths table
include Shell_Acquisition
def self.Column_Definitions
	return [['ip','inet'],
	['protocol','VARCHAR(255)'],
	['port','integer'],
	['portName','VARCHAR(255)']
	]
end

end

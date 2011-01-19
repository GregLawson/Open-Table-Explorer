############################################################################
#    Copyright (C) 2010 by Greg Lawson   #
#    GregLawson@gmail.com   #
#                                                                          #
#    This program is free software; you can redistribute it and#or modify  #
#    it under the terms of the GNU General Public License as published by  #
#    the Free Software Foundation; either version 2 of the License, or     #
#    (at your option) any later version.                                   #
#                                                                          #
#    This program is distributed in the hope that it will be useful,       #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#    GNU General Public License for more details.                          #
#                                                                          #
#    You should have received a copy of the GNU General Public License     #
#    along with this program; if not, write to the                         #
#    Free Software Foundation, Inc.,                                       #
#    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
############################################################################
require 'network.rb'
class Hosts  < ActiveRecord::Base
include Shell_Acquisition
attr_reader :ports
def self.Column_Definitions
	return [['ip','inet'],
	['nmap','text'],
	['otherPorts','integer'], 
	['otherState','VARCHAR(255)'], 
	['mac','text'], 
	['nicVendor','text'], 
	['name','VARCHAR(255)'], 
	['last_detection','timestamp with time zone'], 
	['nmap_execution_time','real']
	]
end
def Hosts.recordDetection(ip,timestamp=Time.new)
	host=Hosts.find_or_initialize_by_ip(ip)
	host.last_detection=timestamp
	host.save
end
def Hosts.nmapScan(candidateIP)
	host=find_or_initialize_by_ip(candidateIP)
	cmd= "nmap  #{candidateIP}"
	puts cmd if $VERBOSE
	nmap=`#{cmd}`
	puts "nmap=#{nmap}" if $DEBUG
	nmap.strip!
	nmap.each_line do |l|
		s = VerboseStringScanner.new(l)
		if s.scan(/Starting Nmap|Interesting ports|PORT|^$|Note: Host seems down/) then
			puts "skipping line=#{l}"    if $DEBUG
		elsif s.scan(/Not shown: /) then
			host.update_attribute('otherPorts', s.scan(/[0-9]+/))
			s.scan(/\s/)
			host.update_attribute('otherState', s.scan(/[a-z]+/))
		elsif s.scan(/MAC Address:\s*/) then
			puts "l=#{l}" if $VERBOSE
			mac= s.scan(/[0-9a-fA-F:]{17}/)
			host.update_attribute('mac', s.scan(/[0-9a-fA-F:]{17}/))
			puts "no spaces after MAC address in #{l}" if s.scan(/\s*/)
			nicVendor=s.scan(/\([a-zA-Z \-0-9]+\)/)
			#puts "nicVendor=#{nicVendor}"
			#puts "nicVendor[1,nicVendor.length-2]=#{nicVendor[1,nicVendor.length-2]}"
			host.update_attribute('nicVendor',  nicVendor[1,nicVendor.length-2])
		elsif s.scan(/All /) then
			host.update_attribute('otherPorts', s.scan(/[0-9]+/))
			s.scan(/\s/)
			host.update_attribute('otherState', s.scan(/[a-z]+/))
		elsif port= s.scan(/[0-9]+/) then
			@ports=find_or_initialize_by_ip_and_port(candidateIP,port)
			@ports.update_attribute('ip', candidateIP)
			@ports.update_attribute('port', port)
			s.scan(/\//)
			@ports.update_attribute('protocol', s.scan(/[tu][cd]p/))
			s.scan(/\s+open\s+/)
			@ports.update_attribute('portName', s.scan(/[a-zA-Z]+/))
			#@ports.sqlValues=@ports.hash2values(@data)
			@ports.save
		elsif s.scan(/Nmap done:/)
			up,nmap_execution_time=Hosts.scanNmapSummary(s)
			if up>'0'
				puts "after if up=#{up}" if $VERBOSE
				host.update_attribute('last_detection', Time.new)
			end
			host.update_attribute('nmap_execution_time', nmap_execution_time)			
		else
			puts "Line not decoded: '#{l}'"
		end
	end
	host.update_attribute('nmap', nmap)
#	update_attribute('last_detection', Time.new)
	host.save
	#@ports.dumpAcquisitions
	#sqlValues=hash2values(@data)
	#dumpHash
	#dumpAcquisitions
end
def Hosts.scanNmapSummary(s)
	puts "s.rest=#{s.rest}" if $VERBOSE
	plural=  s.after(/.*IP address/,/e?s? /)
	up=s.after(/\(/,/[0-9.]+/)
	puts "up=#{up}" if $VERBOSE
	nmap_execution_time= s.after(/ hosts? up\) scanned in /,/[0-9.]+/)
	puts "nmap_execution_time=#{nmap_execution_time}" if $DEBUG
	return [up,nmap_execution_time]
end
end
#puts "Import_Column.firstMatch('192.168.5.254')=#{Import_Column.firstMatch('192.168.5.254')}"
#puts "Import_Column.row2ImportType(Import_Column.firstMatch('192.168.5.254'))=#{Import_Column.row2ImportType(Import_Column.firstMatch('192.168.5.254'))}"
#puts "Import_Column.railsType(Import_Column.firstMatch('192.168.5.254'))=#{Import_Column.railsType(Import_Column.firstMatch('192.168.5.254'))}"
#network=Hosts.new
#puts "network.ports.columnExists('ip')=#{network.ports.columnExists('ip')}"
#puts "network.ports.columnExists('protocol')=#{network.ports.columnExists('protocol')}"
#network.ports.['ip','inet')
#network.acquire
#networks=Networks.new
#networks.scaffold
Networks.acquire

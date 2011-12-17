class Network < ActiveRecord::Base
include Generic_Table
def initialize
	super('Networks')
end #initialize
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
end #Network

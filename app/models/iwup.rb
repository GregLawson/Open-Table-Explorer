require_relative 'shell_command.rb'
puts "$VERBOSE=#{$VERBOSE}"
puts "ARGV=#{ARGV.inspect}"
ESSID=ARGV[0]
BSS=ARGV[1]
ls=ShellCommand.new("ls")
wifi_radar_log= ShellCommand.new("cat /var/log/wifi-radar.log")
if /DHCP client not found, please set this in the preferences/.match(wifi_radar_log.output) then
	puts wifi_radar_log.output
	puts "try /sbin/dhclient"
	wifi_radar_conf= ShellCommand.new("sudo cat /etc/wifi-radar.conf")
	puts wifi_radar_conf.output
end #if
iw= ShellCommand.new("/sbin/iw list")
if ESSID.nil? then
	scan= ShellCommand.new("/sbin/iwlist wlan0 scanning")
	puts "Please enter an ESSID:"
	signal=ShellCommand.new("/sbin/iwlist wlan0 scanning|grep [AEQF][duSr]")
	if signal.output.size<100 then
		ShellCommand.new('/usr/sbin/wifi-radar')
	end #if
	puts signal.output
	exit
end #if
 local_essid= ShellCommand.new("/sbin/iwlist wlan0 scanning|grep #{ESSID}")
if local_essid.output.empty? then
	puts "#{ESSID} not found in scan."
	puts ShellCommand.new("/sbin/iwlist wlan0 scanning|grep [EQF][uSr]").output
else
	puts "#{ESSID} found in scan."
	# puts ShellCommand.new("/sbin/iwlist wlan0 scanning|grep -v Unknown")
	iwconfig= ShellCommand.new("/sbin/iwconfig wlan0")
	matchData=/wlan0     IEEE 802.11bgn  ESSID:"(#{ESSID})/.match(iwconfig.output)
	if matchData.nil? then
		 puts "iwconfig=#{iwconfig.inspect}"
	else
		puts ShellCommand.new("sudo /sbin/iwconfig wlan0 essid \"#{ESSID}").inspect
	end #if
	puts"matchData=#{matchData.inspect}"
	puts ShellCommand.new("/sbin/ifconfig wlan0").output
end #if
scan_dump=ShellCommand.new("/sbin/iw dev wlan0 scan dump")
scan_array=scan_dump.output.split("BSS ")
scan_array.each do |bss|
	essid_matchData=/#{ESSID}/.match(bss)
	bss_matchData=/#{BSS}/i.match(bss)
	if essid_matchData then
		if BSS.nil? then
			puts "scan matches ESSID=#{ESSID} and no BSS was specified, bss=#{bss}"
		elsif bss_matchData then
			puts "scan matches both ESSID=#{ESSID} and BSS=#{BSS}, bss=#{bss}"
			ESSID_BSS_match_found=true
		else
			puts "scan matches ESSID=#{ESSID} but not BSS=#{BSS}, bss=#{bss}" if !ESSID_BSS_match_found
		end #if
	else
		if BSS.nil? then
			#puts "scan does not match ESSID=#{ESSID} and no BSS was specified, bss=#{bss}"
		elsif bss_matchData then
			puts "scan matches BSS=#{BSS} but not ESSID=#{ESSID}, bss=#{bss}"
		else
			#puts "scan matches neither ESSID=#{ESSID} nor BSS=#{BSS}, bss=#{bss}"
		end #if
	end #if
end #each

link_string= ShellCommand.new("/sbin/iw dev wlan0 link")
 link_array=link_string.output.split("\n")
 authentication=link_array[0]
 connection=link_array[1]
 puts "authentication=#{authentication}"
 authenicated_MAC=authentication.split(" ")[2]
 puts "authenicated_MAC=#{authenicated_MAC}"
 
 puts "connection=#{connection}"
if connection=='Not connected.' then
end #if
 
 
nmap_A= ShellCommand.new("nmap -A 172.31.42.254")
if /Note: Host seems down. If it is really up, but blocking our ping probes, try -Pn/.match(nmap_A.output) then
	nmap_blocked= ShellCommand.new("nmap -Pn 172.31.42.254")
	if /RTTVAR has grown to over/.match(nmap_blocked.output) then
		puts "RTTVAR has grown to over, suggests bad network."
	elsif /Host is up /.match(nmap_blocked.output)
		puts "Home router pings blocked."
		puts "nmap_blocked=#{nmap_blocked.output}"
	else
		puts "Home router unreachable."
	end #if
		local_nmap=ShellCommand.new("nmap 172.31.42.1-254")
	puts local_nmap.output
else
	puts ShellCommand.new("ping 172.31.42.254 -c 2").output
end #if
 
puts ShellCommand.new("sudo /sbin/iwlist wlan0 auth").output
 
puts ShellCommand.new("/sbin/route").output
 dhclient= ShellCommand.new("sudo /sbin/dhclient -v wlan0")
if /No broadcast interfaces found - exiting./.match(dhclient.output) then
	ifconfig=ShellCommand.new("/sbin/ifconfig")
	matchData=/B/.match(ifconfig.output)
	puts "matchData=#{matchData.inspect}"
else
	puts "dhclient=#{dhclient} printed to syserr?"
	puts "dhclient=#{dhclient.inspect} printed to syserr?"
end #if

# puts ShellCommand.new("ping 172.31.42.101 -c 2").output
 
puts ShellCommand.new("ping www.yahoo.com -c 2").output
 
 
puts ShellCommand.new("cat /etc/resolv.conf ").output
 
puts ShellCommand.new("ping 209.18.47.61 -c 2").output
 
puts ShellCommand.new("nslookup www.yahoo.com").output
 
puts ShellCommand.new("ping www.yahoo.com -c 2").output

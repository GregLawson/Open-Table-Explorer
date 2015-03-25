#!/usr/bin/ruby
require 'http'
httpaddr = "http://192.168.100.1/system.asp"
data = {}
keys = %w(ReceivePower TransmitPower)
content = HTTP.get(httpaddr).to_s
content.gsub!(/\ /, '')
content.gsub!(/<(?:[^>'"]*|(['"]).*?\1)*>/, '')

# regex in html source order
if (content =~ /Receive Power Level\n&nbsp;(.*) dBmV/) then
	data[:ReceivePower] = $1
end # if
if (content =~ /Transmit Power Level\n&nbsp;(.*) dBmV/) then 
	data[:TransmitPower] = $1
end # if
puts content
puts data.inspect
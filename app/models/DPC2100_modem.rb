#!/usr/bin/ruby
require 'http'
httpaddr = 'http://192.168.100.1/system.asp'
data = {}
keys = %w(ReceivePower TransmitPower)
content = HTTP.get(httpaddr).to_s
content.delete!(' ')
content.gsub!(/<(?:[^>'"]*|(['"]).*?\1)*>/, '')

# regex in html source order
if content =~ /Receive Power Level\n&nbsp;(.*) dBmV/
  data[:ReceivePower] = Regexp.last_match(1)
end # if
if content =~ /Transmit Power Level\n&nbsp;(.*) dBmV/
  data[:TransmitPower] = Regexp.last_match(1)
end # if
puts content
puts data.inspect

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
class WebBoxHistory
def WebBoxFTP2DB(file)
date=file.match('([-0-9]+).csv$')[1]
puts date
File.open(file, "r") do |aFile|
	lineNum=0
	aFile.each_line do |line|
		lineNum=lineNum+1
		if lineNum > 7 then
			@sqlValues=line.split(";")
			sql="INSERT INTO Production_FTP VALUES ("
			@sqlValues.each do |value|		
				@matchpos=(value =~ /^[0-9.]+$/)
				#puts "matchpos num=#{@matchpos}"	
				if @matchpos==0 then	
					sql="#{sql}#{value},"
				else
					@matchpos=(value =~ /^[ \n]*$/)
					#puts "matchpos white=#{@matchpos}"	
					if 0!=(value =~ /^[ \n]*$/)	
						sql="#{sql}'#{value}',"
					else
						sql="#{sql}NULL,"	
					end
				end
				end
			#puts @sqlValues			
			#puts "@sqlValues[0]='#{@sqlValues[0]}'"
			sql= "#{sql}'#{date}');"
			puts sql if $VERBOSE
			if @sqlValues[0]!='' then
				errorMessage  = DB.execute(sql)
			end
			end 
		end
	end
rescue StandardError => e:
 puts "StandardError: " + e.to_s
end
end
class Production
def pollWebBox
current_values=Net::HTTP.get(URI.parse('http://192.168.3.136/current_values.ajax'))
if current_values == 'ABORT' then
	#puts 'web box password needed'
	#wget -nv --user-agent='Mozilla/5.0 (compatible; Konqueror/3.5; Linux) KHTML/3.5.10 (like Gecko) (Debian)' --referer='http://192.168.3.136/home.htm' --header='Accept: text/html, image/jpeg, image/png, text/*, image/*, */*' --header='Accept-Encoding: x-gzip, x-deflate, gzip, deflate' --header='Accept-Charset: utf-8, utf-8;q=0.5, *;q=0.5' --header='Accept-Language: en'  --no-cache --header='Cache-control: no-cache' --user="installer" --password="sma" --keep-session-cookies --save-cookies="cookies.txt" --post-data='Language=en&Password=sma&ButtonLogin=Login' -O data/login.htm "http://User:sma@192.168.1.251/login"
	#post-data='Language=en&Password=sma&ButtonLogin=Login
	Net::HTTP.post_form(URI.parse('http://192.168.3.136/http://User:sma@192.168.3.136/login'),{'Language'=>'en','Password'=>'sma','ButtonLogin'=>'Login'})
	Net::HTTP.get(URI.parse('http://User:sma@192.168.3.136/plant_current.htm?DevKey=WR40U08E:2000673163&DevClass=Sunny%20Boy'))
	current_values=Net::HTTP.get(URI.parse('http://192.168.3.136/current_values.ajax'))
	#puts current_values
	if current_values == 'ABORT' then
		#puts 'password unsuccessful'
		home=Net::HTTP.get(URI.parse('http://192.168.3.136/home.ajax'))
		power=home.match(/\"Power\"\:\"([0-9]+) W/).captures[0].to_f
		#puts "production power=#{power}"
		sql = "INSERT INTO Productions (power,created_at,updated_at) VALUES (#{power},'now','now');"
		#puts sql	
		errorMessage  = DB.execute(sql)
	end
else
	puts current_values
end
return power
rescue Errno::ECONNREFUSED => e
	puts "Errno::ECONNREFUSED: " + e.to_s
rescue Timeout::Error => e:
 	puts "Timeout::Error: " + e.to_s
rescue Errno::EHOSTUNREACH => e:
	puts "Errno::EHOSTUNREACH: " + e.to_s
rescue StandardError => e:
 puts "StandardError: " + e.to_s
end
end


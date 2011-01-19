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
require 'test/unit'
require 'generic.rb'
require 'weather.rb'
class Test_Weather <Test::Unit::TestCase
def test_acquire
	assert_respond_to(MULTIPLE_WEATHER,:acquire,"MULTIPLE_WEATHER does not have an acquire class method.")
	assert_respond_to(MULTIPLE_WEATHER,:getPage,"MULTIPLE_WEATHER does not have an getPage class method.")
#puts "URI.parse(url).methods.inspect=#{URI.parse('http://www.weather.gov/xml/current_obs/KLAX.xml').methods.inspect}"
	assert_respond_to(URI.parse('http://www.weather.gov/xml/current_obs/KLAX.xml'),:request_uri,"URI does not have an request_uri instance method.")

#puts "URI.parse(url).inspect=#{URI.parse(url).inspect}"

	assert_block("Doesn't update databse.") { 
	startCount=MULTIPLE_WEATHER.count
	aq=MULTIPLE_WEATHER.acquire('http://www.weather.gov/xml/current_obs/KHHR.xml')
	variableHash=MULTIPLE_WEATHER.parse(aq)
	variableHash=MULTIPLE_WEATHER.addPrefix(variableHash,'khhr_')
	row=MULTIPLE_WEATHER.new
	row.update_attributes(variableHash)
	mw.save
	MULTIPLE_WEATHER.count>startCount
	}
#	assert_nothing_raised (Errno::ECONNREFUSED) do
#		MULTIPLE_WEATHER.acquire('')
#		end
end # def	

end # class
#MULTIPLE_WEATHER.sample
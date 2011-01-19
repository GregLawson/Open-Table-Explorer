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
require 'webBox.rb'
class Test_Webbox <Test::Unit::TestCase
def test_generic
	assert(TEDWebBoxFull.generic_acquisitions.size>0,"TEDWebBoxFull not defined in Generic_Acquisitions table.")
end # def	
end # class
TEDWebBoxFull.class.relationship(:TEDWebBoxFull_Parse) if $VERBOSE
#end # of module
#$DEBUG=1
#puts "TEDWebBoxFull.class_variables=#{TEDWebBoxFull.class_variables}"
#puts "TEDWebBoxFull.instance_variables=#{TEDWebBoxFull.instance_variables}"

#puts "TEDWebBoxFull.included_modules=#{TEDWebBoxFull.included_modules.inspect}"
#puts "TEDWebBoxFull.class.public_methods=#{TEDWebBoxFull.class.public_methods.inspect}"
TEDWebBoxFull.class.singularTableName  if $VERBOSE
TEDWebBoxFull.class.relationship  if $VERBOSE
TEDWebBoxFull.class.relationship(:TEDWebBoxFull) if $VERBOSE
TEDWebBoxFull.class.relationship(:scaffold)  if $VERBOSE
TEDWebBoxFull.class.relationship(:Column_Definitions) if $VERBOSE
#TEDWebBoxFull.adaptiveAcquisition
#puts TEDWebBoxFull.Column_Definitions
#puts TEDWebBoxFull.class.scaffold(TEDWebBoxFull.Column_Definitions)
#puts TEDWebBoxFull.alterColumns
#puts TEDWebBoxFull.class.whoAmI
#puts Class.class.whoAmI
puts Class.whoAmI(Class) if $VERBOSE
puts Class.whoAmI(TEDWebBoxFull_Parse) if $VERBOSE
puts Class.whoAmI(JSON_Parse) if $VERBOSE
#puts Class.whoAmI(TEDWebBoxFull_Parse::JSON_Parse)
puts Class.whoAmI(Structure_From_Data) if $VERBOSE
puts Class.whoAmI(Structure_From_Data.class) if $VERBOSE
#puts Class.whoAmI(Structure_From_Data.Column_Definitions)
#puts Class.whoAmI(Structure_From_Data::Column_Definitions)
#puts Class.whoAmI(Structure_From_Data::self.Column_Definitions)
#puts TEDWebBoxFull::TEDWebBoxFull_Parse::class.whoAmI
#puts TEDWebBoxFull.TEDWebBoxFull_Parse::JSON_Parse::Structure_From_Data::Column_Definitions.inspect
#exit
def news_search(query, results=10, start=1)
   base_url = "http://search.yahooapis.com/NewsSearchService/V1/newsSearch?appid=YahooDemo&output=json"
   url = "#{base_url}&query=#{URI.encode(query)}&results=#{results}&start=#{start}"
   resp = Net::HTTP.get_response(URI.parse(url))
   data = resp.body

   result = JSON.parse(data)

   # if the hash has 'Error' as a key, we raise an error
   if result.has_key? 'Error' then
      raise "web service error"
   end
   return result
end
#webBoxCurrentValues=TEDWebBoxFull.new('TEDWebBoxFull')
#puts "TEDWebBoxFull.instance_variables=#{webBoxCurrentValues.instance_variables}"
#puts "TEDWebBoxFull.instance_methods=#{webBoxCurrentValues.instance_methods}"
# row=TEDWebBoxFull.new
# dataAcquisition=row.adaptiveAcquisition

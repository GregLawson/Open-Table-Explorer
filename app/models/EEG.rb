###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
#require 'app/models/regexp_tree.rb' # make usable under rake
class Eeg
include Generic_Table
extend Generic_Table::ClassMethods
include NoDB

# Initializes EEG from a hash
def initialize(hash)
	super(hash)
end #initialize
def self.all
	uri=Url.where("href='EEG2'").first
	file_method=StreamMethod.find_by_name('File')
	file_method[:uri]=uri
	file_method.compile_code!
	file_method.fire!
	delimited_method=StreamMethod.find_by_name('Delimited')
	delimited_method[:unparsed]=file_method[:acquisition]
	selection=GenericType.find_by_name('tab')
	delimited_method[:selection]=selection
	delimited_method.compile_code!
	delimited_method.fire!
	return delimited_method[:parsed]
end #all
end #EEG
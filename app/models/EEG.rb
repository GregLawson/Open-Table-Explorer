###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require 'app/models/regexp_tree.rb' # make usable under rake
class EEG
include Generic_Table
include NoDB

# Initializes EEG from a hash
def initialize(hash)
	super(hash)
end #initialize
def EEG.all
	file=Url.where("href='EEG2'").first.url
	file_method=StreamMethod.find_by_name('File')
	file_method[:uri]=file
	file_method.fire!
	return file_method[:acquisition]
end #all
end #EEG
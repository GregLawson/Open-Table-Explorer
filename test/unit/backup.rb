###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/minimal2.rb'
class Minimal2Test < TestCase
include DefaultTests
include TE.model_class?::Examples
def test_rsync
rsync -ruav /mnt/crashed_gui /media/central-greg/
rsync -ruav /mnt/space /media/central-greg/
rsync -ruav /mnt/space/Audiobooks/* /media/central/Music/past/Audiobooks/
rsync -ruav /media/usb0/My_Videos/* /media/central/Videos/
rsync -ruav /media/usb0/* /media/central-greg/WD1TB/usb0/
end # rsync
end #Minimal

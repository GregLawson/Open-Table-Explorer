#!/usr/bin/env ruby
###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################

require 'usb'
require 'optparse'

USB_RT_PORT = USB::USB_TYPE_CLASS | USB::USB_RECIP_OTHER
USB_PORT_FEAT_POWER = 8

def list_usb2_hub
  USB.devices.find_all {|d|
    0x200 <= d.bcdDevice &&
    d.bDeviceClass == USB::USB_CLASS_HUB
  }
end

require 'pp'

def power_on(h, port)
  h.usb_control_msg(USB_RT_PORT, USB::USB_REQ_SET_FEATURE, USB_PORT_FEAT_POWER, port, "", 0)
end

def power_off(h, port)
  h.usb_control_msg(USB_RT_PORT, USB::USB_REQ_CLEAR_FEATURE, USB_PORT_FEAT_POWER, port, "", 0)
end



USB.find_bus(bus).find_device(device).open {|h|
}

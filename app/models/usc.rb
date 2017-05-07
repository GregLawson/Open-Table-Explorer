###########################################################################
#    Copyright (C) 2014 by Greg Lawson
#    <GregLawson123@gmail.com>
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/parse.rb'
require_relative '../../app/models/shell_command.rb'
class Usc
  module ClassMethods
  end # ClassMethods
  module Constants
    Usc_filename = 'ttyUSB1'.freeze
    Usc_path = '/dev/' + Usc_filename
    Sys_pattern = /tty[UA].*$/.capture(:tty_filename)
    FTDI_ttys = Dir['/sys/bus/usb-serial/drivers/ftdi_sio/ttyUSB*'].map { |path| path.parse(Sys_pattern)[:tty_filename] }
  end # Constants
  include Constants
  # Usc_file.gets # attr_reader
  def initialize(filename)
    @filename = filename
    #	@file = File.open(path)
  end # initialize

  def path
    '/dev/' + @filename
  end # path

  def status
    File::Stat.new(@filename)
  end # status

  def screen
	ShellCommands.new('screen -D -m /dev/' + @filename)
  end # screen
  # require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions(message = '')
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples
    include Constants
    First_usc_filename = FTDI_ttys[0]
    First_usc = Usc.new(First_usc_filename)
  end # Examples
end # Usc

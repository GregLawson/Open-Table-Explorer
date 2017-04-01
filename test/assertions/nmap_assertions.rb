###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/nmap.rb'
class Nmap # < ActiveRecord::Base
  require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_xml(parsed_xml)
        keys = parsed_xml['nmaprun'].keys.each do |key|
          assert_includes(%w(scaninfo verbose debugging host runstats scanner args
                             start startstr version xmloutputversion), key)
        end # each
        assert_equal(%w(type protocol numservices services), parsed_xml['nmaprun']['scaninfo'].keys)
        parsed_xml['nmaprun']['host'].enumerate(:each) do |host|
          message = 'host = ' + host.inspect
          assert_equal(%w(status address hostnames ports times starttime endtime), host.keys, message.inspect)
          assert_equal(%w(status address hostnames ports times starttime endtime), host.keys)
          assert_equal(%w(addr addrtype), host['address'].keys)
          assert_equal(%w(extraports port), host['ports'].keys)
          #		assert_equal([0, 1, 2, 3, 4], host["ports"]["port"].keys)
          host['ports']['port'].each_with_index do |port, index|
            assert_instance_of(Fixnum, index)
            assert_instance_of(Hash, port)
            assert_equal(%w(state service protocol portid), port.keys)
            assert_equal(%w(name method conf), port['service'].keys)
            assert_includes(['ssh', 'rpcbind', 'netbios-ssn', 'microsoft-ds', 'samba-swat', 'telnet', 'domain', 'http'], port['service']['name'])
          end # each
        end # enumerate
      end # xml

      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
      end # assert_post_conditions
    end # ClassMethods
    def assert_xml(_parsed_xml)
      Nmap.assert_xml(@nmap)
    end # assert_xml

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
    # My_host_nmap_simplified_xml = My_host_nmap.xml["nmaprun"]
    Eth0_network = '192.168.1.1-254'.freeze
    Eth0_network_nmap = Nmap.new(ip_range: Eth0_network)
    Failed_nmap = Nmap.new(ip_range: '192.168.1.1-2')
  end # Examples
end # Nmap

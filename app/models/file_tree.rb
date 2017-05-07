###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require 'rom-csv'
require 'dry-types'
require_relative '../../app/models/stream_tree.rb'
class FileTree
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
  end # DefinitionalConstants
  include DefinitionalConstants
  include Virtus.value_object
  values do
    attribute :root_pathname, Pathname
  end # values
  module ClassMethods
    include DefinitionalConstants
    def file_type(file)
      if File.exist?(file)
        ret = File.ftype(file).to_sym
        if ret == :file
          if File.zero?(file)
            :zero_length
          elsif File.file?(file)
            :data
          else
            :file
          end # if
        else
          ret
        end # if
      else
        :nonexistant_path
      end # if
    rescue StandardError => exception_raised
      exception_raised
    end # file_type

    def recurse?(file)
      file_type(file) == :directory # not link (can cause infinite loops)
    end # recurse?

    def data_hash_value(absolute_pathname)
      file_type = file_type(absolute_pathname)
      case file_type
      when :data then IO.read(absolute_pathname).chomp
      when :link then 
				symbolic_link = File.readlink(absolute_pathname)
				File.expand_path(symbolic_link, File.dirname(absolute_pathname)) # get absolute not relative path
      else
        file_type
        end # if
    rescue StandardError => exception_raised
      exception_raised
    end # data_hash_value

    def path_hash_value(path)
      if file_type(path) == :directory
        directory_hash_value(path)
      else
        data_hash_value(path)
      end # if
    end # path_hash_value

    # terminates for link files to avoid recursion
    def directory_hash_value(directory)
      ret = {}
      Dir[directory + '/*'].each do |absolute_path|
        if (block_given? && yield(absolute_path)) || recurse?(absolute_path)
          ret = ret.merge(File.basename(absolute_path).to_sym => FileTree.directory_hash_value(absolute_path))
        else
          ret = ret.merge(File.basename(absolute_path).to_sym => FileTree.data_hash_value(absolute_path))
        end # if
      end # each
      ret
    end # directory_hash_value

    # provide path around termination condition for links
    def file_tree(directory)
      directory_hash_value(directory) { |file| recurse?(file) || file_type(directory) == :link }
    end # file_tree
		
		def link_dir_to_file_tree(top_directory)
			device_hashes = []
			file_tree_hash = FileTree.file_tree(top_directory)

			file_tree_hash.each_pair do |name, symlink|
				file = File.expand_path(symlink, top_directory)
				sub_tree = FileTree.directory_hash_value(file)
				device_hashes << sub_tree
			end # each
			device_hashes
		end # link_dir_to_file_tree
  end # ClassMethods
  extend ClassMethods
  module Constants # constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
  end # Constants
  include Constants
  require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
        #	asset_nested_and_included(:ClassMethods, self)
        #	asset_nested_and_included(:Constants, self)
        #	asset_nested_and_included(:Assertions, self)
        self
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
        self
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
      self
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
      self
    end # assert_post_conditions
		
		def assert_file_tree(directory)
			assert_equal(:directory, FileTree.file_type(directory), FileTree.file_type(directory))
			assert_equal(true, FileTree.recurse?(directory), FileTree.file_type(directory))
			assert_equal([:lo, :eth0, :wlan0], FileTree.directory_hash_value(directory).keys, FileTree.directory_hash_value(directory).inspect)
			file_tree = FileTree.file_tree(directory)
			assert_equal([:lo, :eth0, :wlan0], file_tree.keys, file_tree.inspect)
			assert_equal([:lo, :eth0, :wlan0], file_tree.keys, file_tree.inspect)
			common_keys = [] # initialize
			known_common_keys = [:uevent, :subsystem, :addr_assign_type, :addr_len, :dev_id, :ifalias, :iflink, :ifindex, :type, :link_mode, :address, :broadcast, :carrier, :speed, :duplex, :dormant, :operstate, :mtu, :flags, :tx_queue_len, :netdev_group, :statistics, :power, :queues]
			net_device_trees = {}
			Dir[Net_directory + '/*'].map do |net_device|
				net_device_tree = FileTree.file_tree(net_device)
				keys = net_device_tree.keys
				if common_keys == []
					common_keys = keys
				else
					common_keys = keys && common_keys
				end # if
				assert_equal([], known_common_keys - keys, net_device_tree.inspect)
				assert_equal([], known_common_keys - common_keys, net_device_tree.inspect)
				net_device_trees = net_device_trees.merge(net_device => net_device_tree)
			end # each
			assert_equal(["/sys/class/net/lo", "/sys/class/net/eth0", "/sys/class/net/wlan0"], net_device_trees.keys, net_device_trees.inspect)
			assert_equal(known_common_keys, common_keys, net_device_trees.inspect)

			empty_keys = [:uevent, :addr_assign_type, :addr_len, :dev_id, :ifalias, :iflink, :ifindex, :type, :link_mode, :address, :broadcast, :carrier, :speed, :duplex, :dormant, :operstate, :mtu, :flags, :tx_queue_len, :netdev_group]
			net_device_trees.keys.each do |device|
				message = 'device = ' + device.inspect
				assert_equal(file_tree, net_device_trees[device][:subsystem], message)
				untested_keys = known_common_keys - [:subsystem]


				statistics = net_device_trees[device][:statistics]
				assert_instance_of(Hash, statistics, message)
				statistics.each_pair do |key, value|
					assert_instance_of(Symbol, key, message)
					assert_instance_of(String, value, message)
					assert_equal(value, value.to_i.to_s, message)
				end # each
				untested_keys = untested_keys - [:statistics]

				power = net_device_trees[device][:power]
				assert_instance_of(Hash, power, message)
				power.each_pair do |key, value|
					assert_instance_of(Symbol, key, message)
				end # each
				assert_equal(power[:runtime_usage], power[:runtime_usage].to_i.to_s, message)
				assert_equal(power[:runtime_active_kids], power[:runtime_active_kids].to_i.to_s, message)
				assert_equal(power[:runtime_suspended_time], power[:runtime_suspended_time].to_i.to_s, message)
				assert_equal(power[:runtime_active_time], power[:runtime_active_time].to_i.to_s, message)
				assert_includes(["disabled"], power[:async], message)
				assert_includes(["unsupported"], power[:runtime_status], message)
				assert_includes(["disabled"], power[:runtime_enabled], message)
				assert_includes(["auto"], power[:control], message)
				assert_kind_of(Exception, power[:autosuspend_delay_ms], message)
				untested_keys = untested_keys - [:power]

				queues = net_device_trees[device][:queues]
				assert_instance_of(Hash, queues, message)
				queues.each_pair do |key, value|
					assert_instance_of(Symbol, key, message)
				end # each
					assert_instance_of(Hash, queues[:"rx-0"], message)
					assert_instance_of(Hash, queues[:"tx-0"], message)
				assert_equal(queues[:"rx-0"][:rps_flow_cnt], queues[:"rx-0"][:rps_flow_cnt].to_i.to_s, message)
				assert_equal(queues[:"tx-0"][:tx_timeout], queues[:"tx-0"][:tx_timeout].to_i.to_s, message)
				queues[:"rx-0"][:rps_cpus].split(',').each do |field|
					assert_equal(field, '00000000', message)
				end # split
				queues[:"tx-0"][:xps_cpus].split(',').each do |field|
					assert_equal(field, '00000000', message)
				end # split
				untested_keys = untested_keys - [:queues]

				untested_keys.each do |key|
					message = 'device = ' + device.inspect
					message += "\nkey = " + key.inspect
					value = net_device_trees[device][key]
					message += "\nvalue = " + value.inspect
					if value.instance_of?(String)
						assert_instance_of(String, value, message)
					elsif empty_keys.include?(key)
						assert_equal({}, value)
					elsif value.instance_of?(Hash)
						assert_instance_of(Hash, value, message)
					else
						assert_instance_of(String, value, message)
					end # if
					
					assert_includes([{}], value, message)
				end # each
			end # each
		end # file_tree
		
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    include DefinitionalConstants
    include Constants
    Net_directory = '/sys/class/net'.freeze
    Net_file_tree_hash = FileTree.file_tree(Net_directory)
    Lo_hash = FileTree.directory_hash_value(Net_directory + '/lo')
		Known_common_keys = [:uevent, :subsystem, :addr_assign_type, :addr_len, :dev_id, :ifalias, :iflink,
			:ifindex, :type, :link_mode, :address, :broadcast, :carrier, :speed, :duplex, :dormant,
			:operstate, :mtu, :flags, :tx_queue_len, :netdev_group, :statistics, :power, :queues]
  end # Examples
end # FileTree

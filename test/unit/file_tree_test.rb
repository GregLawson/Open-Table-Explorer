###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/file_tree.rb'
class FileTreeTest < TestCase
  # include DefaultTests
  include RailsishRubyUnit::Executable.model_class?::Examples
  def test_file_type
    assert_equal(:directory, FileTree.file_type(Net_directory))
    assert_equal(:link, FileTree.file_type(Net_directory + '/lo'))
    assert_equal(:directory, FileTree.file_type(Net_directory + '/lo/')) # slash matters!
    assert_equal(:link, FileTree.file_type(Net_directory + '/lo/subsystem'))
    assert_equal(:data, FileTree.file_type(Net_directory + '/lo/uevent'))
    assert_equal(:characterSpecial, FileTree.file_type('/dev/null'))
    assert_equal(:data, FileTree.file_type(Net_directory + '/lo/duplex')) # can't read
    assert_equal(:nonexistant_path, FileTree.file_type(Net_directory + '/lo/phys_port_id'))
    assert_equal(:directory, FileTree.file_type('/dev/disk'))
    assert_equal(:directory, FileTree.file_type('/dev/bus'))
  end # file_type

  def test_recurse?
    assert(FileTree.recurse?(Net_directory))
    refute(FileTree.recurse?(Net_directory + '/lo/subsystem'), FileTree.file_type(Net_directory + '/lo/subsystem'))
    refute(FileTree.recurse?(Net_directory + '/lo/uevent'))
  end # recurse?

  def test_data_hash_value
    assert_equal(:characterSpecial, FileTree.data_hash_value('/dev/null'))
    assert_equal('0x0', FileTree.data_hash_value(Net_directory + '/lo/dev_id'))
    assert_equal(:directory, FileTree.data_hash_value(Net_directory))
    #	assert_equal('#<Errno::EOPNOTSUPP: Operation not supported @ io_fread - /sys/class/net/lo/phys_port_id>', FileTree.data_hash_value(Net_directory + '/lo/phys_port_id').values[0].inspect)
    assert_equal('#<Errno::EINVAL: Invalid argument @ io_fread - /sys/class/net/lo/duplex>', FileTree.data_hash_value(Net_directory + '/lo/duplex').inspect)
    assert_equal('/class/net', FileTree.data_hash_value(Net_directory + '/lo/subsystem'))
  end # data_hash_value

  def test_path_hash_value
    assert_equal(:characterSpecial, FileTree.path_hash_value('/dev/null'))
    assert_equal('0x0', FileTree.path_hash_value(Net_directory + '/lo/dev_id'))
    assert_equal('0x0', Lo_hash[:dev_id])
    assert_includes(Lo_hash.keys, :statistics)
    assert_equal(23, Lo_hash[:statistics].size, Lo_hash.inspect)
    assert_includes(Lo_hash[:statistics].keys, :rx_errors)

    assert_equal('/sys/devices/virtual/net/lo', FileTree.path_hash_value(Net_directory + '/lo'))
    assert_equal({}, Lo_hash - FileTree.path_hash_value(Net_directory + '/lo/'))
    assert_equal(:link, FileTree.path_hash_value(Net_directory + '/eth0'))
    assert_equal(:link, FileTree.path_hash_value(Net_directory + '/wlan0'))
    path = Net_directory
    assert_equal(:directory, FileTree.file_type(path))
    net_hash_value = FileTree.path_hash_value(path)
    assert_equal([:net], net_hash_value.keys, net_hash_value.inspect)
  end # path_hash_value

  def test_directory_hash_value
    #	assert_equal(31, Lo_hash.size)
    assert_equal('0x0', Lo_hash[:dev_id])
    assert_equal({}, FileTree.directory_hash_value('/dev/null'))
    directory = Net_directory + '/lo'
    ret = {}
    assert_includes(Dir[directory + '/*'], '/sys/class/net/lo/statistics')
    Dir[directory + '/*'].each do |file|
      if FileTree.recurse?(file)
        ret = ret.merge(File.basename(file).to_sym => FileTree.directory_hash_value(file))
        refute_empty(ret.keys, ret)
      elsif FileTree.file_type(file) == :link
        ret = ret.merge(File.basename(file).to_sym => File.readlink(file))
      elsif File.file?(file) && !File.zero?(file)
        ret = ret.merge(File.basename(file).to_sym => FileTree.data_hash_value(file))
           end # if
    end # each
    assert_equal(ret.keys.size, Dir[directory + '/*'].size)
    refute_nil(ret)
    assert_instance_of(Hash, ret)
    assert_equal({}, Lo_hash - ret)
    assert_instance_of(Hash, ret[:lo])
    assert_equal([:lo, :eth0, :wlan0], ret.keys)
    assert_equal(3, ret.values.size, ret)
    assert_equal(ret[:wlan0].keys, ret[:eth0].keys, ret)
    ret = FileTree.file_tree('/sys/class/net/*')
    assert_instance_of(Hash, ret)
    assert_instance_of(Hash, ret[:lo])
    #	assert_equal([:lo, :eth0, :wlan0], ret.keys)
    #	assert_equal(3, ret.values.size, ret)
    #	assert_equal(ret[:wlan0].keys, ret[:eth0].keys, ret)
    #	assert_equal(ret[:wlan0].keys, ret[:lo].keys, ret)
  end # directory_hash_value

  def test_assert_file_tree
  end # file_tree

  def test_link_dir_to_file_tree
    device_hashes = []
    top_directory = Net_directory
    file_tree_hash =	Net_file_tree_hash
    assert_operator(2, :<=, file_tree_hash.size, file_tree_hash.inspect)
    file_tree_hash.each_pair do |name, symlink|
      file = File.expand_path(symlink, top_directory)
      #			File.exist?(file)
      puts 'name = ' + name.to_s + ' symlink = ' + symlink + ' file = ' + file.to_s
      assert_pathname_exists(file)
      sub_tree = FileTree.directory_hash_value(file)
      assert_instance_of(Hash, sub_tree)
      assert_operator(24, :<=, sub_tree.keys.size, sub_tree.inspect) # net fully populated?
      assert_operator(17, :<=, sub_tree.values.uniq.size, sub_tree.inspect) # net diverse values?
      device_hashes << sub_tree
    end # each
    assert_instance_of(Array, device_hashes, device_hashes.inspect)
    assert_operator(2, :<=, device_hashes.size, device_hashes.inspect)
    assert_instance_of(Array, FileTree.link_dir_to_file_tree(top_directory))
  end # link_dir_to_file_tree

  def test_assert_file_tree
    directory = Net_directory
    assert_equal(:directory, FileTree.file_type(directory), FileTree.file_type(directory))
    assert_equal(true, FileTree.recurse?(directory), FileTree.file_type(directory))
    directory_hash_value = FileTree.directory_hash_value(directory)
    assert_includes(directory_hash_value.keys, :lo)
    assert_includes(directory_hash_value.keys, :wlan0)
    file_tree = FileTree.file_tree(directory)
    assert_includes(file_tree.keys, :lo, file_tree.inspect)
    assert_includes(file_tree.keys, :wlan0, file_tree.inspect)
    common_keys = [] # initialize
    net_device_trees = {}
    Dir[Net_directory + '/*'].map do |net_device|
      net_device_tree = FileTree.file_tree(net_device)
      keys = net_device_tree.keys
      common_keys = if common_keys == []
                      keys
                    else
                      keys && common_keys
                    end # if
      assert_equal([], Known_common_keys - keys, net_device_tree.inspect)
      assert_equal([], Known_common_keys - common_keys, net_device_tree.inspect)
      net_device_trees = net_device_trees.merge(net_device => net_device_tree)
    end # each
    assert_includes(net_device_trees.keys, '/sys/class/net/lo')
    assert_includes(net_device_trees.keys, '/sys/class/net/wlan0')
    assert_equal(Known_common_keys, common_keys, net_device_trees.inspect)

    empty_keys = [:uevent, :addr_assign_type, :addr_len, :dev_id, :ifalias, :iflink, :ifindex, :type, :link_mode, :address, :broadcast, :carrier, :speed, :duplex, :dormant, :operstate, :mtu, :flags, :tx_queue_len, :netdev_group]
    net_device_trees.keys.each do |device|
      message = 'device = ' + device.inspect
      assert_equal(file_tree, net_device_trees[device][:subsystem], message)
      untested_keys = Known_common_keys - [:subsystem]

      statistics = net_device_trees[device][:statistics]
      assert_instance_of(Hash, statistics, message)
      statistics.each_pair do |key, value|
        assert_instance_of(Symbol, key, message)
        assert_instance_of(String, value, message)
        assert_equal(value, value.to_i.to_s, message)
      end # each
      untested_keys -= [:statistics]

      power = net_device_trees[device][:power]
      assert_instance_of(Hash, power, message)
      power.each_pair do |key, _value|
        assert_instance_of(Symbol, key, message)
      end # each
      assert_equal(power[:runtime_usage], power[:runtime_usage].to_i.to_s, message)
      assert_equal(power[:runtime_active_kids], power[:runtime_active_kids].to_i.to_s, message)
      assert_equal(power[:runtime_suspended_time], power[:runtime_suspended_time].to_i.to_s, message)
      assert_equal(power[:runtime_active_time], power[:runtime_active_time].to_i.to_s, message)
      assert_includes(['disabled'], power[:async], message)
      assert_includes(['unsupported'], power[:runtime_status], message)
      assert_includes(['disabled'], power[:runtime_enabled], message)
      assert_includes(['auto'], power[:control], message)
      assert_kind_of(Exception, power[:autosuspend_delay_ms], message)
      untested_keys -= [:power]

      queues = net_device_trees[device][:queues]
      assert_instance_of(Hash, queues, message)
      queues.each_pair do |key, _value|
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
      untested_keys -= [:queues]

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

  def test_eth0
    assert_includes(Net_file_tree_hash.values, '/sys/devices/pci0000:00/0000:00:1c.0/0000:01:00.0/net/eth0', Net_file_tree_hash)
    assert_includes(Net_file_tree_hash.keys, :eth0, Net_file_tree_hash)
    link_dir_to_file_tree = FileTree.link_dir_to_file_tree(Net_directory)

    assert_includes(link_dir_to_file_tree.keys, :eth0, link_dir_to_file_tree.inspect)
  end # eth0

  def test_Examples
  end # Examples
end # FileTree

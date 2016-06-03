###########################################################################
#    Copyright (C) 2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/samba.rb'
class SambaTest < TestCase
  # include DefaultTests
  include RailsishRubyUnit::Executable.model_class?::Examples
  def test_Constants
    line = Samba::Examples::Comment_line
    capture = line.capture?(Comment_regexp)
    assert_operator(1, :<=, capture.output[:comment].size)
    assert_equal(nil, capture.output[:filesystem_image])
    assert_equal(nil, capture.output[:mount_point])
    assert_equal(nil, capture.output[:file_system_type])
    assert_equal(nil, capture.output[:options])
    line = Samba::Examples::Comment_line
    capture = line.capture?(Mount_table_regexp)
    assert_kind_of(Capture, capture, 'capture should not be nil; raw_captures can be nil')
    assert_operator(1, :<=, capture.output[:comment].size)
    assert_equal(nil, capture.output[:filesystem_image])
    assert_equal(nil, capture.output[:mount_point])
    assert_equal(nil, capture.output[:file_system_type])
    assert_equal(nil, capture.output[:options])
    line = Samba::Examples::Test_line
    fstab_regexp = File_system_image_regexp.capture(:filesystem_image)
    capture = line.capture?(Comment_regexp | fstab_regexp)
    assert_kind_of(Capture, capture, 'capture should not be nil; raw_captures can be nil')
    assert_equal(nil, capture[:comment])
    assert_equal('//Seagate-414103/Public', capture.output[:filesystem_image])

    fstab_regexp *= Whitespace_delimiter * Pathname_regexp.capture(:mount_point)
    capture = line.capture?(Comment_regexp | fstab_regexp)
    assert_kind_of(Capture, capture, 'capture should not be nil; raw_captures can be nil')
    assert_equal(nil, capture[:comment])
    assert_equal('//Seagate-414103/Public', capture.output[:filesystem_image])
    assert_equal('/media/central', capture.output[:mount_point])

    fstab_regexp *= Whitespace_delimiter * Fs_type_regexp.capture(:file_system_type)
    capture = line.capture?(Comment_regexp | fstab_regexp)
    assert_kind_of(Capture, capture, 'capture should not be nil; raw_captures can be nil')
    assert_equal(nil, capture[:comment])
    assert_equal('//Seagate-414103/Public', capture.output[:filesystem_image])
    assert_equal('/media/central', capture.output[:mount_point])
    assert_equal('cifs', capture.output[:file_system_type])

    fstab_regexp *= Whitespace_delimiter * Options_regexp.capture(:options)
    capture = line.capture?(Comment_regexp | fstab_regexp)
    assert_kind_of(Capture, capture, 'capture should not be nil; raw_captures can be nil')
    assert_equal(nil, capture[:comment])
    assert_equal('//Seagate-414103/Public', capture.output[:filesystem_image])
    assert_equal('/media/central', capture.output[:mount_point])
    assert_equal('cifs', capture.output[:file_system_type])
    assert_equal(Samba::Examples::Options_string, capture.output[:options])

    fstab_regexp = Mount_table_regexp
    capture = line.capture?(Mount_table_regexp)
    assert_kind_of(Capture, capture, 'capture should not be nil; raw_captures can be nil')
    assert_equal(nil, capture[:comment])
    assert_equal('//Seagate-414103/Public', capture.output[:filesystem_image])
    assert_equal('/media/central', capture.output[:mount_point])
    assert_equal('cifs', capture.output[:file_system_type])
    assert_equal(Samba::Examples::Options_string, capture.output[:options])
    Smb_domains.assert_pre_conditions
    Smb_servers.assert_pre_conditions
    Smb_tree.assert_pre_conditions
  end # Constants

  def test_workgroups
    assert_includes(Samba.workgroups, Default_workgroup,	Smb_domains.output.capture?(Smb_tree_workgroup_regexp).inspect)
  end # workgroups

  def test_servers
    assert_includes('', Smb_servers.output.capture?(Smb_tree_regexp, LimitCapture))
    assert_includes('', Samba.servers(Samba::Examples::Default_workgroup))
  end # servers

  def test_tree
    workgroup = Default_workgroup
    server = ''
    assert_instance_of(Hash, Samba.tree(Samba::Examples::Default_workgroup, Samba::Examples::Default_server), Smb_tree.inspect)
    assert_includes(Default_share, Samba.tree(Samba::Examples::Default_workgroup, Samba::Examples::Default_server).values, Smb_tree.inspect)
  end # tree

  def test_parse_options
    options_string = 'ip=1.2.3.4,unix'
    assert_equal({ ip: '1.2.3.4', unix: nil }, Samba.parse_options(options_string))
    options = Samba.parse_options(Samba::Examples::Options_string)
    assert_instance_of(Hash, options)
    assert_equal(nil, options[:auto])
    assert_equal(nil, options[:rw])
    assert_equal('/home/greg/.samba/credentials/central', options[:credentials])
    assert_equal('0777', options[:file_mode])
    assert_equal('0777', options[:dir_mode])
    assert_equal(nil, options[:serverino])
    assert_equal(nil, options[:acl])
    ping = ShellCommands.new('ping -n -q -c 1 ' + options[:ip])
    ping.assert_pre_conditions
    assert_equal(0, ping.process_status.exitstatus, ping.inspect)
    assert_equal(Default_server, options[:ip])
  end # parse_options

  def test_new_from_table
    fstab = IO.read('/etc/fstab')
    lines = fstab.split("\n").map do |line|
      capture = line.capture?(Mount_table_regexp)
      assert_kind_of(Capture, capture)
      assert_instance_of(MatchCapture, capture)
      refute_nil(capture.raw_captures, capture.inspect)
      if capture.output[:comment]
        nil
      else
        assert_equal(nil, capture.output[:comment], capture.inspect)
        refute_nil(capture.output[:options], capture.inspect)
        options_hash = Samba.parse_options(capture.output[:options])
        host = options_hash[:ip]
        Samba.new(host, capture.output[:filesystem_image],
                  capture.output[:mount_point],
                  options_hash
                 )
      end # if
    end # each
  end # new_from_table

  def test_fstab
    fstab = IO.read('/etc/fstab')
    lines = fstab.split("\n").each do |line|
      Samba.new_from_table(line)
    end # each
  end # fstab

  def mtab
  end # mtab

  def test_mount
    mount_point = '/media/central'
    central = Samba.new(Default_server, '\\Seagate-414103/Public', mount_point, 'auto')
    central.mount.assert_post_conditions
    assert_equal(central.mount_point)
    puts '!File.exists?(central.mount_point) = ' + !File.exist?(central.mount_point)
    puts 'File.exists?(central.mount_point) = ' + File.exist?(central.mount_point)
    puts 'central.mount_point = ' + central.mount_point
    assert_equal(true, central.mounted?)
  end # mount

  def test_umount
    mount_point = '/media/central'
    central = Samba.new(Default_server, '\\Seagate-414103/Public', mount_point, 'auto')
    central.assert_post_conditions
    assert_equal(false, central.mounted?)
    central.assert_unmounted
  end # umount

  def test_mounted?
    mount_point = '/tmp/this_shouldnt_exist'
    central = Samba.new(Default_server, '\\Seagate-414103/Public', mount_point, 'auto')
    mtab_grep = ShellCommands.new('grep ' + central.mount_point + ' /etc/mtab')
    assert_equal('', mtab_grep.output)
    assert(central.mounted?)
    central.assert_mounted
  end # mounted?
end # Samba

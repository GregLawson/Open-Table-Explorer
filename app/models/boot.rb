###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
# require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/version.rb'
require_relative '../../app/models/parse.rb'
class Boot
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    module Regexps
      module Grub
        Terminator = /\{\n/
        Uuid_regexp = /[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}/.capture(:uuid)
        Linux_version_regexp = Version::Semantic_version_regexp * /-amd64/.capture(:architecture)
        Vmlinuz_regexp = /\/vmlinuz-/ * Linux_version_regexp
        Paranthesized_init = /\(/ * /sysvinit|recovery mode/.capture(:menu_title) * /\)/
        Paranthetic_title_regexp = /\(/ * /on \/dev\/sda[0-9]+/.capture(:menu_title) * /\)/
        Menu_title_regexp = Linux_version_regexp * / / * Paranthetic_title_regexp * (/ / * Paranthesized_init).group * Regexp::Optional
        Menuentry_name_regexp = /menuentry \'Debian GNU\/Linux/ * /, with Linux / * Regexp::Optional * Menu_title_regexp * /\'/
        Classes_regexp = / --class gnu-linux --class gnu --class os /
        Menuentry_id_option_regexp = /\$menuentry_id_option / * /\'osprober-gnulinux-/ * Vmlinuz_regexp * /--/ * Uuid_regexp * /\'/
        Menuentry_regexp = Menuentry_name_regexp * Classes_regexp * Menuentry_id_option_regexp
        Kernel_options_regexp = / ro / * /quiet|single/.capture(:single) * / init=\/lib\/sysvinit\/init/.group * Regexp::Optional
        Boot_line_regexp_array = [Regexp::Start_string * /\t{1,3}/.capture(:indent) * /linux /, Vmlinuz_regexp, / root=UUID=/,  Uuid_regexp, Kernel_options_regexp]
        Full_regexp_array =  Boot_line_regexp_array + [ /\n\t/ * Menuentry_regexp * / / * Terminator]
        Full_regexp = Regexp[Full_regexp_array]
        #	full_regexp = Start_string * /\tlinux / * vmlinuz_regexp * / root=UUID=/ * uuid_regexp * / ro quiet\n\tmenuentry 'Debian GNU\/Linux (on /dev/sda10)' --class gnu-linux --class gnu --class os $menuentry_id_option 'osprober-gnulinux-/vmlinuz-4.6.0-1-amd64--51e0851a-6300-4d9a-b27e-e4a5b5db7bac' {\n/
        end # Grub
        include Grub
      end # Regexp
      module Acquisitions
        Run_levels = ShellCommands.new('/sbin/runlevel')
        Init_default = ShellCommands.new('grep initdefault /etc/inittab')
        Is_system_running = ShellCommands.new('systemctl is-system-running')
        Uname = ShellCommands.new('uname -a')
        Boot_history_command_string = 'zgrep --no-filename -P "Command line: " /var/log/messages* >>test/data_sources/messages/kernel_boot && sudo chown greg test/data_sources/messages/kernel_boot'
        Systemd_targets = ShellCommands.new('systemctl --plain --no-legend')
      end # Acquisitions
      include Regexps
      include Acquisitions
  end # DefinitionalConstants
  include DefinitionalConstants
	
  module DefinitionalClassMethods
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods
  include Virtus.value_object
  values do
    attribute :os_version, Version
    #	attribute :age, Fixnum, :default => 789
    #	attribute :timestamp, Time, :default => Time.now
  end # values
	
	def state
		
	end # state
	
  module Constructors # such as alternative new methods
    include DefinitionalConstants
  end # Constructors
  extend Constructors
	
  module ReferenceObjects # constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
  end # ReferenceObjects
  include ReferenceObjects
	
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
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    include DefinitionalConstants
    include ReferenceObjects
		Grubs_run = ShellCommands.new('grep "linux .*/vmlinu" /boot/grub/grub.cfg')
		One_menu_entry = "\tlinux /vmlinuz-4.6.0-1-amd64 root=UUID=976bed30-38d8-43a3-a4d4-6869fb636fcb ro quiet\n\tmenuentry 'Debian GNU/Linux (on /dev/sda10)' --class gnu-linux --class gnu --class os $menuentry_id_option 'osprober-gnulinux-/vmlinuz-4.6.0-1-amd64--51e0851a-6300-4d9a-b27e-e4a5b5db7bac' {\n"
  end # Examples
end # Boot

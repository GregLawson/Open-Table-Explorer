###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/schedule.rb'
class Minimal2Test < TestCase
  # include DefaultTests
  include RailsishRubyUnit::Executable.model_class?::Examples
	def test_bottlenecked?
	end # bottlenecked?
	
	def test_cores
		lines = ShellCommands.new('grep cores /proc/cpuinfo').output.split("\n").uniq
		line = lines[0]
		assert_match(Cpu_info_regexp, line)
		assert_equal(4, line.capture?(Cpu_info_regexp).output[:cores].to_i)
		assert_equal(4, Schedule.cores)
	end # cores

	def test_load_average
	end # idle_cpus

	def test_cpus
	end # cpus

	def test_memory
	end # memory

  def test_Virtus
  end # values
	def test_scheduler
		
	end # scheduler
	def test_change_working_directory
	end # change_working_directory

	def test_find_trouble
	end # find_trouble

	def test_push
	end # push

	def test_cleanup
	end # cleanup
	
	def test_pull
	end # pull

	def test_run_slower_tests
	end # run_slower_tests
	
	def test_run_slowest_tests
	end # run_slowest_tests
end # Minimal

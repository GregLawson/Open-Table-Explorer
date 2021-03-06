###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/default_test_case.rb'
require_relative '../../app/models/stream_method_argument.rb' # in test_helper?
require_relative '../../config/initializers/monkey/String.rb'
class StreamMethodArgumentTest < TestCase
#  include DefaultTests2
  include StreamMethodArgument::Examples
  def test_initialize
    arg = StreamMethodArgument.first
    arg.assert_invariant
    arg.assert_post_conditions
    no_db = StreamMethodArgument.new(:new_name, :input)
    no_db.assert_invariant
    no_db.assert_pre_conditions
    no_db.assert_post_conditions
  end # initialize

  def test_gui_name
    assert_equal('@URL', First_stream_argument.gui_name)
  end # gui_name

  def test_instance_name_reference
    assert_equal('self[:URL]', First_stream_argument.instance_name_reference)
  end # instance_name_reference

  def test_id_equal
    #	assert_test_id_equal
  end # test_id_equal
end # StreamMethodArgument

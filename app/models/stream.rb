###########################################################################
#    Copyright (C) 2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class Stream # < Enumerator::Lazy
  module ClassMethods
  end # ClassMethods
  extend ClassMethods
  def initialize(*args)
    @buffer = if args.size = 1
                [args]
              else
                args
              end # if
  end # initialize
  module Assertions
    module ClassMethods
      def assert_post_conditions
    end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions
    end # assert_pre_conditions

    def assert_post_conditions
    end # assert_post_conditions
  end # Assertions
  include Assertions
  # TestWorkFlow.assert_pre_conditions
  module Constants
  end # Constants
  include Constants
  module Examples
    include Constants
  end # Examples
  include Examples
end # Stream

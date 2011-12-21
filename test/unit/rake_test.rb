require 'test/test_helper'
require 'ftools'
require 'lib/tasks/testing.rb'
require 'active_support' # for singularize and pluralize
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class RakeTest < ActiveSupport::TestCase
# mimic Rake function
end #class
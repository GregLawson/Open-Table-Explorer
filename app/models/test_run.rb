class TestRun < ActiveRecord::Base
include Generic_Table
has_many :bugs
end

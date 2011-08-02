class ErrorType < ActiveRecord::Base
include Generic_Table
belongs_to :test_runs
end

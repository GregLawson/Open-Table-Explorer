class Edison < ActiveRecord::Base
include Generic_Table
has_many :ted_primaries
end

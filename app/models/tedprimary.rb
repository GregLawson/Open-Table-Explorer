class Tedprimary < ActiveRecord::Base
include Generic_Table
has_many :edisons
end

class Huelseries < ActiveRecord::Base
include Generic_Table
has_many :huel_shows
end

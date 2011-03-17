class TableSpec < ActiveRecord::Base
has_many :acquisition_stream_specs
has_one :frequency
include Global
end

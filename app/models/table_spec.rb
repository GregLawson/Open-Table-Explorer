class TableSpec < ActiveRecord::Base
has_many :acquisition_stream_specs
belongs_to :frequency
include Global
end

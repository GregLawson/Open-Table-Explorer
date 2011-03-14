class TableSpec < ActiveRecord::Base
has_many :acquisition_stream_specs
include Global
end

class AddStreamPatternIdToStreamMethod < ActiveRecord::Migration
  def self.up
    add_column :stream_methods, :stream_pattern_id, :integer
  end

  def self.down
    remove_column :stream_methods, :stream_pattern_id
  end
end

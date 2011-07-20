class CreateStreamPatterns < ActiveRecord::Migration
  def self.up
    create_table :stream_patterns do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :stream_patterns
  end
end

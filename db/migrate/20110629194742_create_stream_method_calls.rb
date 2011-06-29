class CreateStreamMethodCalls < ActiveRecord::Migration
  def self.up
    create_table :stream_method_calls do |t|
      t.integer :id
      t.integer :stream_method_id

      t.timestamps
    end
  end

  def self.down
    drop_table :stream_method_calls
  end
end

###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class CreateStreamLinks < ActiveRecord::Migration
  def self.up
    create_table :stream_links do |t|
      t.integer :id
      t.integer :input_stream_method_argument_id
      t.integer :output_stream_method_argument_id
      t.integer :store_method_id
      t.integer :next_method_id

      t.timestamps
    end
  end

  def self.down
    drop_table :stream_links
  end
end

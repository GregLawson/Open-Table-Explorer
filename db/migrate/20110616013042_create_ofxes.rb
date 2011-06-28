class CreateOfxes < ActiveRecord::Migration
  def self.up
    create_table :ofxes do |t|
      t.integer :cuisp
      t.decimal :units
      t.decimal :unit_price
      t.decimal :total
      t.string :account_number
      t.timestamp :trade_date
      t.timestamp :settle_date
      t.string :memo
      t.string :direction
      t.string :transfer_type

      t.timestamps
    end
  end

  def self.down
    drop_table :ofxes
  end
end

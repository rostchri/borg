class CreateTorrents < ActiveRecord::Migration
  def self.up
    create_table :torrents do |t|
      t.string :title
      t.string :srcid
      t.text :detail
      t.date :timestamp
      t.timestamps
    end
  end

  def self.down
    drop_table :torrents
  end
end

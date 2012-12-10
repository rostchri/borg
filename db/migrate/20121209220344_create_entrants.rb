class CreateEntrants < ActiveRecord::Migration
  def self.up
    create_table :entrants do |t|
      t.string            :title
      t.string            :type
      t.string            :srcid
      t.string            :srcurl
      t.has_attached_file :thumbnail
      t.string            :category
      t.date              :date
      t.text              :other
      t.timestamps
    end
  end
  def self.down
    drop_table :entrants
  end
end

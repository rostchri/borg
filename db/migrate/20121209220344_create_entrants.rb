class CreateEntrants < ActiveRecord::Migration
  def self.up
    create_table :entrants do |t|
      t.string            :title
      t.string            :type
      t.string            :srcid
      t.string            :srcurl
      t.number            :update_counter, :default => 0
      t.has_attached_file :image
      t.string            :imageurl
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


# ActiveRecord::Migration.change_column :entrants, :date, :datetime
# ActiveRecord::Migration.rename_column :entrants, :thumbnail_file_name, :image_file_name
# ActiveRecord::Migration.rename_column :entrants, :thumbnail_content_type, :image_content_type
# ActiveRecord::Migration.rename_column :entrants, :thumbnail_updated_at, :image_updated_at
# ActiveRecord::Migration.add_column :entrants, :imageurl, :string
# ActiveRecord::Migration.add_column :entrants, :update_counter, :integer, :default => 0
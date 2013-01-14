class CreateEntrants < ActiveRecord::Migration
  def self.up
    create_table :entrants do |t|
      t.string            :type
      t.string            :title
      t.string            :category
      t.string            :srcid
      t.string            :imdbid
      t.string            :srcurl
      t.string            :author
      t.text              :content, :limit => 64.kilobytes + 1
      t.has_attached_file :image
      t.string            :imageurl
      t.number            :update_counter, :default => 0
      t.date              :date
      t.text              :other, :limit => 64.kilobytes + 1
      t.text              :diff, :limit => 64.kilobytes + 1
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
# ActiveRecord::Migration.add_column :entrants, :diff, :text
# ActiveRecord::Migration.add_column :entrants, :content, :text
# ActiveRecord::Migration.add_column :entrants, :author, :string
# ActiveRecord::Migration.change_column :entrants, :content, :text, :limit => 64.kilobytes + 1
# ActiveRecord::Migration.change_column :entrants, :diff, :text, :limit => 64.kilobytes + 1
# ActiveRecord::Migration.change_column :entrants, :other, :text, :limit => 64.kilobytes + 1
# ActiveRecord::Migration.add_column :entrants, :imdbid, :string

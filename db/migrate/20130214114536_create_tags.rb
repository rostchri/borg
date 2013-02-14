class CreateTags < ActiveRecord::Migration
  def up
    create_table   :tags, :id => true  do |t|
      t.references :tagable, :polymorphic => true
      t.references :label
    end
    add_index :tags, ["tagable_type","tagable_id"], :name => "index_tags_on_tagable_type_and_tagable_id", :unique => true
    add_index :tags, ["label_id"],                  :name => "index_tags_on_label_id", :unique => true
  end

  def down
    drop_table :tags
  end
end
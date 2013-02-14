class CreateLabels < ActiveRecord::Migration
  def up
    create_table   :labels do |t|
      t.string     :name
      t.string     :key
      t.text       :description
      t.timestamps
    end
  end

  def down
    drop_table :labels
  end
end
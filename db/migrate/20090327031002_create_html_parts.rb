class CreateHtmlParts < ActiveRecord::Migration
  def self.up
    create_table :html_parts do |t|
      t.belongs_to :user
      t.string :urn
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :html_parts
  end
end

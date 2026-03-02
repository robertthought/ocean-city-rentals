class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :meta_description
      t.text :content, null: false
      t.text :excerpt
      t.string :featured_image_url
      t.boolean :published, default: false, null: false
      t.datetime :published_at
      t.string :author, default: "Bob Idell"
      t.string :category
      t.string :tags

      t.timestamps
    end
    add_index :articles, :slug, unique: true
    add_index :articles, :published
    add_index :articles, :published_at
    add_index :articles, :category
  end
end

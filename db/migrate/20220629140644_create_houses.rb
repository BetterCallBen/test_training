class CreateHouses < ActiveRecord::Migration[6.0]
  def change
    create_table :houses do |t|
      t.references :city, null: false, foreign_key: true
      t.string :project
      t.string :name
      t.text :description
      t.text :image_url
      t.string :address
      t.string :status
      t.integer :price
      t.integer :rooms
      t.integer :surface
      t.integer :borough_id
      t.boolean :balcony, default: false
      t.boolean :chimney, default: false
      t.boolean :cellar, default: false
      t.boolean :parking, default: false
      t.boolean :terrace, default: false
      t.boolean :garden, default: false

      t.timestamps
    end
  end
end
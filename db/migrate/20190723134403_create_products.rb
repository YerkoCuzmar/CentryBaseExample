class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string  :sku
      t.integer :stock
      t.float   :price
      t.integer :last_stock_reported_centry
      t.float   :last_price_reported_centry
      t.string  :id_variant_centry
      t.string  :id_product_centry
      t.timestamps
    end
  end
end

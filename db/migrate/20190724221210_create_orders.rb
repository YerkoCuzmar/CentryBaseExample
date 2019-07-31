class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string  :centry_id
      t.string  :integration_id
      t.timestamps
    end
  end
end

class CreateWebhooks < ActiveRecord::Migration[5.2]
  def change
    create_table :webhooks do |t|
      t.string  :centry_id
      t.string  :link
      t.timestamps
    end
  end
end

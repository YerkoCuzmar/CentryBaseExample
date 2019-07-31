class RemoveColumnIdVariantCentryFromProduct < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :id_variant_centry
  end
end

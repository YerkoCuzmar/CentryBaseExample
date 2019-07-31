class RemoveCentryVariantModel < ActiveRecord::Migration[5.2]
  def change
    drop_table(:centry_variants)
  end
end

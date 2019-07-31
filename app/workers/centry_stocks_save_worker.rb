##
# Esta clase envía los cambios de stock de los productos de la base de datos local hacia Centry.

class CentryStocksSaveWorker < CentryWorker
  include Sidekiq::Worker
  sidekiq_options queue: :integration_default, retry: 0, backtrace: true

  #Actualiza el stock del producto en Centry, solo si el ultimo stock informado desde Centry es distinto al stock
  # registrado en la base de datos local, actualiza en la base de datos local el ultimo stock registrado en Centry.
  def perform
    update_null = " or (stock is null and last_stock_reported_centry is not null)"
    query = "stock <> last_stock_reported_centry or ((stock is not null and last_stock_reported_centry is null)#{update_null if ENV["UPDATE_NULL_STOCK"] == "false"})"

    ::Product.where(query).each do |local_product|
      resp = centry.put('/conexion/v1/variants/sku.json', {}, {"sku": local_product[:sku], "quantity": local_product[:stock]})
      if (resp.code == "200")
        centry_variant_info = JSON.parse(resp.body)
        local_product[:last_stock_reported_centry]  = centry_variant_info["quantity"]
        local_product[:id_product_centry]           = centry_variant_info["product_id"]
        local_product.save!
      end
    end
  end
end
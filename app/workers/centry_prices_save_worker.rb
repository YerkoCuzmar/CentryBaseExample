
# Esta clase maneja los cambios de precios de los productos de la base de datos local hacia Centry.
class CentryPricesSaveWorker < CentryWorker
  include Sidekiq::Worker
  sidekiq_options queue: :integration_default, retry: 3, backtrace: true

  #Actualiza el precio del producto en Centry y actualiza en la base de datos local el ultimo precio registrado en Centry.
  def perform
    centry_ids_prices.each do |product|
      if product[0].present? && product[1].present?
        resp = centry.put("/conexion/v1/products/#{product[0]}.json", {}, {"price_compare": product[1]})
        if (resp.code == "200")
          centry_product_info = JSON.parse(resp.body)
          ::Product.where(id_product_centry: centry_product_info["_id"]).each do |local_product|
            local_product[:last_price_reported_centry]  = centry_product_info["price_compare"]
            local_product.save!
          end
        end
      end
    end
  end

  private

  #Retorna listado de productos de la base de datos local con su precio. En caso de tener mas de un
  # producto local con un mismo id de Centry retorna el producto con mayor o menor precio (Configurable).
  # @return [Array] cada elemento del arreglo tiene la forma [centry_product_id, precio]
  def centry_ids_prices
    ordered_variants = ::Product.where.not(id_product_centry: [nil, ""]).order("id_product_centry, price").pluck(:id_product_centry, :price)
    ordered_variants.group_by{|pid, price| pid}.map { |pid, price| ENV["UPDATE_WITH_MAX_PRICE"] == "true" ? price.max() : price.min()}
  end
end

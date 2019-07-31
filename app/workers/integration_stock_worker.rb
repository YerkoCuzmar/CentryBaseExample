##
# Esta clase recibe los cambios de stock de los productos provenientes desde la integración y los guarda en la base de datos local.

class IntegrationStockWorker < IntegrationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :integration_default, retry: 3, backtrace: true

  # Metodo crea o actualiza en la base de datos local el stock de todos los productos provenientes de la integración.
  # Y llama al metodo CentryStocksSaveWorker para guardar sus stock respectivos en Centry.
  def perform
    products = JSON.parse(integration.get('/rest/V1/products?searchCriteria=[]').body).dig("items")
    products.each do |product|
      sku = product.dig("sku")
      if sku.present?
        product_qty = JSON.parse(integration.get("/rest/V1/products/#{sku}").body).dig("extension_attributes", "stock_item", "qty")

        local_product         = ::Product.find_or_create_by(:sku => sku)
        local_product[:stock] = product_qty if product_qty.present?
        local_product.save!
      end
    end
    CentryStocksSaveWorker.perform_async
  end
end

##
# Esta clase recibe los cambios de precios de los productos provenientes desde la integración y los guarda en la base de datos local.

class IntegrationPriceWorker < IntegrationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :integration_default, retry: 3, backtrace: true

  # Metodo crea o actualiza en la base de datos local el precio de todos los productos provenientes de la integración.
  # Y llama al metodo CentryPricesSaveWorker para guardar sus precios respectivos en Centry.
  def perform
    products = JSON.parse(integration.get('/rest/V1/products?searchCriteria=[]').body)["items"]
    products.each do |product|
      local_product = ::Product.find_or_create_by(:sku => product["sku"])
      local_product[:price] = product["price"]
      local_product.save!
    end
    CentryPricesSaveWorker.perform_async
  end
end

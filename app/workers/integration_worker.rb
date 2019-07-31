# Esta clase representa una instancia de la API de la integración.
# Se configura en +app/config/environments/{development|production|test}.rb+
class IntegrationWorker

  protected

  # Crea una instancia de la integración para hacer uso de su API.
  # @return [Object] SDK de la integracion.
  def integration
    if @integration_sdk.nil?
      @integration_sdk = Magento2.new(ENV["HOST"], ENV["USERNAME"], ENV["PASSWORD"])
      @integration_sdk.admin_token
    end
    @integration_sdk
  end

end

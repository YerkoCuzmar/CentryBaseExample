# Esta clase representa una instancia de la API de Centry.
# Se configura en +app/config/environments/{development|production|test}.rb+
class CentryWorker

  protected

  # Crea una instancia de Centry para hacer uso de su API.
  # @return [Object] SDK de centry.
  def centry
    if @centry_sdk.nil?
      @centry_sdk = Centry.new(ENV["CENTRY_CLIENT_ID"], ENV["CENTRY_SECRET"], ENV["CENTRY_REDIRECT_URI"])
      @centry_sdk.client_credentials(ENV["CENTRY_SCOPE"])
    end
    @centry_sdk
  end
end
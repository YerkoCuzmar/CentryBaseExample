##
# Esta clase maneja las notificaciones que llegan a través de los webhooks registrados en Centry.

class NotificationListenerWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5, backtrace: true

  sidekiq_retry_in do |count|
    1800 # Se reintenta cada 30 minutos
  end

  # sidekiq_retries_exhausted do |msg|
  #   case (msg["args"].first["topic"] rescue nil)
  #   when "on_order_save"
  #     UserMailer.ax_create_sales_order_completed_b2_b_errors(msg["args"].first["order_id"], msg["error_message"]).deliver_later
  #   when "on_async_task_finished" #, "on_async_task_failed"
  #   end
  # end


  # Llama a distintos metodos dependiendo del tópico proveniente de los parametros de la notificación recibida desde Centry.
  # @param [Hash] params parámetros provenientes del post en el link registrado como webhook en Centry.
  def perform(params)
    case params["topic"]
    when "on_order_save"
      order_save(params["order_id"])
    when "on_async_task_finished" #, "on_async_task_failed"
      async_task_finished(params["async_task_id"])
    end
  end

  #Si es que la orden proveniente de Centry no está registrada, se crea una orden en la integración de destino y se
  # registra en la base de datos local la relacion entre la orden de Centry y la orden de la integración.
  # @param id[String] id de orden en centry.
  def order_save(id)
    centry_order = JSON.parse(centry.request("conexion/v1/orders/#{id}.json", :get).body)
    local_order = ::Order.find_by(centry_id: centry_order["_id"])
    if local_order.nil?
      integration_order = Translations::Order.centry_to_integration(centry_order)
      resp = integration.put('/rest/V1/orders/create', nil, integration_order)
      if resp.code == "200"
        resp_body = JSON.parse(resp.body)
        local_order = ::Order.find_or_create_by(:integration_id => resp_body["entity_id"])
        local_order[:centry_id] = centry_order["_id"]
        local_order.save!
      else
        # Handle error on integration
      end
    end
  end

  def async_task_finished(id)
    # TODO: async_task_finished
  end

  private


  # Crea una instancia de Centry para hacer uso de su API.
  # @return [Object] SDK de centry.
  def centry
    if @centry_sdk.nil?
      @centry_sdk = Centry.new(ENV["CENTRY_CLIENT_ID"], ENV["CENTRY_SECRET"], ENV["CENTRY_REDIRECT_URI"])
      @centry_sdk.client_credentials(ENV["CENTRY_SCOPE"])
    end
    @centry_sdk
  end

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

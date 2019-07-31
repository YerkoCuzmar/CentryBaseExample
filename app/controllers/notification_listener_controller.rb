##
# Este controlador recibe las notificaciones del link registrado en los webhooks de Centry.

class NotificationListenerController < ApplicationController
  skip_before_action :verify_authenticity_token

  # Comienza el worker para recibir las notificaciones de Centry.
  def listen
    NotificationListenerWorker.perform_async(notification_params)
    render plain: ''
  end

  private
  def notification_params
    JSON.parse(params.require(:notification_listener).permit(
      :topic, :product_id, :order_id, :integration_config_id, :async_task_id
    ).to_json)
  end

end

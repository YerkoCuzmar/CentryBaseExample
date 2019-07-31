# Esta clase tranforma las ordenes hacia el formato necesitadp por la integración de destino.
class Translations::Order

  # El método recibe una orden de Centry y la transforma al formato de la orden necesitada por la integración.
  # @param centry_order [Hash] Orden proveniente de Centry.
  # @return Hash con formato aceptado por la integración.
  def self.centry_to_integration(centry_order)

    address_shipping_key = centry_order.dig('address_shipping', 'line1').present? && centry_order.dig("address_shipping", "city").present? ? "address_shipping" : "address_billing"

    my_items = []
    centry_order["items"].each do |item|
      my_item = {
        "base_price_incl_tax": item.dig("unit_price").to_f * item.dig("quantity").to_f,
        "qty_ordered": item.dig("quantity"),
        "sku": item.dig("variant", "sku")
      }
      my_items << my_item
    end
    my_integration_order = {
      # hash minimo requerido por Magento
      :entity => {
        :base_grand_total       => centry_order.dig("total_amount"),
        :base_shipping_incl_tax => centry_order.dig("shipping_amount"),
        :customer_email         => centry_order.dig(address_shipping_key, "email"),
        :customer_firstname     => centry_order.dig("buyer_first_name"),
        :customer_lastname      => centry_order.dig("buyer_last_name"),
        :items                  => my_items,
        :billing_address        => {
          :city       => centry_order.dig(address_shipping_key, "city"),
          :country_id => centry_order.dig(address_shipping_key, "country"),
          :firstname  => centry_order.dig("buyer_first_name"),
          :lastname   => centry_order.dig("buyer_last_name"),
          :postcode   => centry_order.dig(address_shipping_key, "zip_code"),
          :street     => [centry_order.dig(address_shipping_key, "line1")],
          :telephone  => centry_order.dig(address_shipping_key, "phone1"),
        },
        :payment => {
          :method => "checkmo"
        }
      }
    }
    return my_integration_order
  end
end

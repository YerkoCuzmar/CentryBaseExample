
if @centry_sdk.nil?
  @centry_sdk = Centry.new(ENV["CENTRY_CLIENT_ID"], ENV["CENTRY_SECRET"], ENV["CENTRY_REDIRECT_URI"])
  @centry_sdk.client_credentials(ENV["CENTRY_SCOPE"])
end
@centry_sdk

order_webhook = {
  :callback_url => "#{ENV["BASE_URL"]}/notification_test_listener",
  :on_order_save => true
}

match_webhook = nil
Webhook.all.each do |wh|
  resp = @centry_sdk.get("/conexion/v1/webhooks/#{wh["centry_id"]}.json")
  code = resp.code
  parsed_resp = JSON.parse(resp.body)
  if code == "200" && parsed_resp["on_order_save"] && parsed_resp["callback_url"] == order_webhook[:callback_url]
    match_webhook = parsed_resp
  elsif code == "404"
    wh.destroy
  end
end

if match_webhook.nil?
  new_webhook = @centry_sdk.post("/conexion/v1/webhooks.json", nil, order_webhook)
  if new_webhook.code == "200"
    new_webhook = JSON.parse(new_webhook.body)
    new_local_webhook = Webhook.new
    new_local_webhook["centry_id"] = new_webhook["_id"]
    new_local_webhook["link"] = new_webhook["callback_url"]
    new_local_webhook.save!
  end
end

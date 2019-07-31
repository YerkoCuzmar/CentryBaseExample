
cron_jobs= [
  {
    'name'  => 'integration_price_cron_job',
    'class' => 'IntegrationPriceWorker',
    'cron'  => ENV["PRICE_UPDATE_INTERVAL"],
  },
  {
    'name'  => 'integration_stock_cron_job',
    'class' => 'IntegrationStockWorker',
    'cron'  => ENV["STOCK_UPDATE_INTERVAL"]
  }
]

Sidekiq::Cron::Job.load_from_array cron_jobs
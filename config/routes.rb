Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq/cron/web'

  mount Sidekiq::Web => '/sidekiq'
  match 'notification_listener', to: 'notification_listener#listen', via: :all

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

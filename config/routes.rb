Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  root 'tests#index'
  resource :test, only: [] do
    get 'echo', to: 'tests#echo_params'
    get 'payment', to: 'tests#payment_notification'
    get 'users', to: 'tests#sync_users'
  end

  resource :payment, only: [] do
    post :report
  end

  resources :users, only: [:create, :destroy] do

  end

  namespace :paynet do
    resource :tom, only: [] do
      get :wsdl
      post :action
    end
    resource :itest, only: [] do
      get :wsdl
      post :action
    end
  end

  namespace :click do
    post :tom, to: 'providers#tom'
    post :erkatoy, to: 'providers#erkatoy'
    post :itest, to: 'providers#itest'
  end
end

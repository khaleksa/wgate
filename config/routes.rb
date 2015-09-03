Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  root 'pages#index'
  get 'errors', to: 'pages#access_errors'

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
    resource :scud, only: [] do
      get :wsdl
      post :action
    end    
  end

  namespace :click do
    post :tom, to: 'providers#tom'
    post :erkatoy, to: 'providers#erkatoy'
    post :itest, to: 'providers#itest'
    post :scud, to: 'providers#scud'
  end
end

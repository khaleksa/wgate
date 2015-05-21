Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'test#index'
  get 'test/echo', to: 'test#echo_params'

  resource :payment, only: [] do
    get :report
  end

  namespace :paynet do
    resource :tom, only: [] do
      get :wsdl
      post :action
    end
  end

  namespace :click do
    post :tom, to: 'providers#tom'
    post :erkatoy, to: 'providers#erkatoy'
  end
end

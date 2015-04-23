Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'test#index'

  get 'paynet/wsdl', to: 'paynets#wsdl'
  post 'paynet/action', to: 'paynets#action'

  get 'test/echo', to: 'test#echo_params'
end

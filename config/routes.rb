Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  get 'paynet/wsdl', to: 'paynets#wsdl'
  post 'paynet/action', to: 'paynets#action'

  post 'click/sync', to: 'click#sync'
end

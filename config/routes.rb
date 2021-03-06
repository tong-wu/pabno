Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'questions#index'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'signout', to: 'sessions#destroy', as: 'signout'

  put 'questions/vote/:vote', to: 'questions#vote'


  resources :sessions, only: [:create, :destroy]
  resources :questions, only: [:index, :show, :create,]

end

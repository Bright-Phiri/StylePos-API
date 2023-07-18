# frozen_string_literal: true

require 'sidekiq/web'
Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  mount ActionCable.server => '/cable'
  mount Sidekiq::Web => '/sidekiq'
  namespace :api do
    namespace :v1 do
      resources :categories do
        resources :items do
          resources :inventory_levels, except: [:index, :destory]
        end
      end
      resources :dashboard, only: :index
      resources :inventory_levels, only: [:index, :destroy]
      resources :returns, only: :index
      resources :orders, only: [:index, :show, :destroy] do
        post '/return_item/:line_item_id', action: :return_item, controller: 'returns'
      end
      get '/find_item/:barcode', action: :find_item, controller: 'items'
      resources :customers
      get '/filter_transactions', action: :find, controller: 'orders'
      resources :employees do
        resources :orders, except: [:index, :show, :destory] do
          resources :line_items, only: [:create, :update, :destroy]
          put '/apply_discount/:id', action: :apply_discount, controller: 'line_items'
        end
      end
      post '/disable_user/:id', action: :disable_user, controller: 'employees'
      post '/activate_user/:id', action: :activate_user, controller: 'employees'
      post '/login', action: :login, controller: 'authentication'
      post '/register', action: :set_manager, controller: 'employees'
      put '/update_password/:id', action: :change, controller: 'passwords'
      post '/forgot_password', action: :forgot, controller: 'passwords'
      post '/reset_password', action: :reset, controller: 'passwords'
    end
  end
end

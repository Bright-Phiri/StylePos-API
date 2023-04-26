# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  mount ActionCable.server => '/cable'
  namespace :api do
    namespace :v1 do
      resources :items do
        resources :inventory_levels, except: [:index, :destory]
      end
      resources :dashboard, only: :index
      resources :inventory_levels, only: [:index, :destroy]
      resources :orders, only: [:index, :show, :destroy] do
        delete 'return_item/:line_item_id', action: :return_item, controller: 'orders'
      end
      resources :customers
      resources :employees do
        resources :orders, except: [:index, :show, :destory] do
          resources :line_items, only: [:create, :update, :destroy]
          put 'apply_discount/:id', action: :apply_discount, controller: 'line_items'
        end
      end
      post 'login', action: :login, controller: 'authentication'
      post 'register', action: :set_manager, controller: 'employees'
      put 'update_password/:id', action: :change, controller: 'passwords'
      post 'forgot_password/:id', action: :forgot, controller: 'passwords'
      post 'reset_password/:id', action: :reset, controller: 'passwords'
    end
  end
end

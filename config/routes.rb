# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      resources :items do
        resources :inventory_levels, except: [:index, :destory]
      end
      resources :inventory_levels, only: [:index, :destroy]
      resources :orders, only: [:index, :show]
      resources :customers
      resources :employees do
        resources :orders, except: [:index, :show] do
          post 'add_line_item', action: :add_line_item, controller: 'orders'
          delete 'remove_line_item/:id', action: :remove_line_item, controller: 'orders'
          post 'set_total_price', action: :set_total_price, controller: 'orders'
        end
      end
    end
  end
end

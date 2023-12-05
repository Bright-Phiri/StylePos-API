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
        collection do
          get '/show_items/:id', action: :show_items, controller: 'categories'
        end
        resources :items, shallow: true, except: [:index, :destroy] do
          resources :inventory_levels, except: [:index, :destroy]
        end
      end
      resources :configurations, except: :index
      resources :dashboard, only: :index
      resources :inventory_levels, only: [:index, :destroy]
      resources :items, only: [:index, :destroy] do
        collection do
          get '/find_item/:barcode', action: :find_item, controller: 'items'
        end
      end
      resources :returns, only: :index
      resources :orders, only: [:index, :show, :destroy] do
        collection do
          get '/filter_transactions', action: :find, controller: 'orders'
        end
        post '/return_item/:line_item_id', action: :return_item, controller: 'returns'
      end
      resources :customers
      resources :employees do
        collection do
          post '/disable_user/:id', action: :disable_user, controller: 'employees'
          post '/activate_user/:id', action: :activate_user, controller: 'employees'
          post '/register', action: :set_manager, controller: 'employees'
        end
        resources :orders, except: [:index, :show, :destory], shallow: true do
          resources :line_items, only: [:create, :update, :destroy] do
            collection do
              put '/apply_discount/:id', action: :apply_discount, controller: 'line_items'
            end
          end
        end
      end
      resources :authentication, except: [:index, :create, :show, :update, :destroy] do
        collection do
          post '/login', action: :login, controller: 'authentication'
        end
      end
      resources :passwords, except: [:index, :create, :show, :update, :destroy] do
        collection do
          put '/update_password/:id', action: :change, controller: 'passwords'
          post '/forgot_password', action: :forgot, controller: 'passwords'
          post '/reset_password', action: :reset, controller: 'passwords'
        end
      end
    end
  end
end

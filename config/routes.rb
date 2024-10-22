# frozen_string_literal: true

require 'sidekiq/web'
Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  mount Sidekiq::Web => '/sidekiq'
  namespace :api do
    namespace :v1 do
      resources :categories do
        get 'show_items', on: :member
        resources :items, shallow: true, except: [:index, :destroy] do
          resources :inventory_levels, except: [:index, :destroy]
          resources :received_items, only: :create
        end
      end
      resources :received_items, except: :create
      resources :tax_rates
      resources :inventory_levels, only: [:index, :destroy]
      resources :items, only: [:index, :destroy] do
        collection do
          get 'find_item/:barcode', action: :find_item, controller: 'items'
        end
      end
      resources :returns, only: :index
      resources :orders, only: [:index, :show, :destroy] do
        get 'search', on: :collection
        post 'return_item/:line_item_id', action: :return_item, controller: 'returns'
      end
      resources :customers
      resources :employees do
        member do
          patch 'disable_user'
          patch 'activate_user'
        end
        post 'register', on: :collection
        resources :orders, except: [:index, :show, :destory], shallow: true do
          resources :line_items, only: [:create, :update, :destroy] do
            patch 'apply_discount', on: :member
          end
        end
      end
      resources :authentication, only: [] do
        post 'login', on: :collection
      end
      resources :passwords, except: [:index, :create, :show, :update, :destroy] do
        patch 'update_password', on: :member
        collection do
          post 'forgot_password'
          post 'reset_password'
        end
      end
    end
  end
end

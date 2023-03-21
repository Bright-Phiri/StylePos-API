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
      resources :dashboard, only: :index
      resources :inventory_levels, only: [:index, :destroy]
      resources :orders, only: [:index, :show, :destroy]
      resources :customers
      resources :employees do
        resources :orders, except: [:index, :show, :destory] do
          resources :line_items, only: [:create, :update, :destroy]
        end
      end
      post 'login', action: :login, controller: 'authentication'
    end
  end
end

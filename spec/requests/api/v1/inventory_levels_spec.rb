# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Inventory Levels API', type: :request do
  let!(:category) { FactoryBot.create(:category, name: 'Clothing', description: 'Clothing') }
  let!(:item) { FactoryBot.create(:item, category:, name: 'Tommy Hilfiger T-shirt', price: '24000', size: 'L', color: 'Black') }
  let!(:item1) { FactoryBot.create(:item, category:, name: 'Tommy H T-shirt', price: '25000', size: 'M', color: 'Black') }
  let(:user) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Store Manager', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
  let(:headers) { authenticated_headers(user) }

  before do
    FactoryBot.create(:inventory_level, item:, quantity: 10, reorder_level: 4, supplier: 'Tommy Hilfiger')
  end

  describe 'GET /api/v1/inventory_levels' do
    it 'returns a list of inventory levels with pagination' do
      get '/api/v1/inventory_levels', params: { page: 1, per_page: 1 }, headers: headers
      expect(response).to have_http_status(:success)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to have_key('inventory_levels')
      expect(parsed_response).to have_key('total')
      expect(parsed_response['inventory_levels']).to be_an(Array)
      expect(parsed_response['inventory_levels'].size).to eq(1)
    end

    it 'returns all inventory_levels when pagination parameters are not provided' do
      get '/api/v1/inventory_levels', headers: headers
      expect(response).to have_http_status(:success)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to have_key('inventory_levels')
      expect(parsed_response).to have_key('total')
      expect(parsed_response['inventory_levels']).to be_an(Array)
    end

    it 'returns filtered inventory_levels when search parameter is provided' do
      get '/api/v1/inventory_levels', params: { search: 'Tommy Hilfiger T-shirt' }, headers: headers
      expect(response).to have_http_status(:success)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to have_key('inventory_levels')
      expect(parsed_response).to have_key('total')
      expect(parsed_response['inventory_levels']).to be_an(Array)
      expect(parsed_response['inventory_levels'].size).to eq(1)
    end
  end

  describe 'POST /api/v1/categories/:category_id/items/:item_id/inventory_levels' do
    it 'creates a new inventory level' do
      inventory_level_params = { quantity: 10, reorder_level: 4, supplier: 'Tommy Hilfiger' }
      post "/api/v1/categories/#{category.id}/items/#{item1.id}/inventory_levels", params: { inventory_level: inventory_level_params }, headers: headers

      expect(response).to have_http_status(:created)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['quantity']).to eq(10)
    end
  end

  describe 'PUT /api/v1/categories/:category_id/items/:item_id/inventory_levels/:id' do
    let!(:inventory_level) { FactoryBot.create(:inventory_level, item: item1, quantity: 10, reorder_level: 4, supplier: 'Tommy Hilfiger') } 
    it 'updates the inventory level' do
      updated_params = { quantity: 15, reorder_level: 6, supplier: 'Updated Supplier' }
      patch "/api/v1/categories/#{category.id}/items/#{item.id}/inventory_levels/#{inventory_level.id}", params: { inventory_level: updated_params }, headers: headers
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['quantity']).to eq(15)
    end

    it 'returns unprocessable entity status when inventory level attributes are invalid' do
      updated_params = { quantity: 0, reorder_level: 100, supplier: 'Updated Supplier' }
      patch "/api/v1/categories/#{category.id}/items/#{item.id}/inventory_levels/#{inventory_level.id}", params: { inventory_level: updated_params }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/v1/inventory_levels/:id' do
    let!(:inventory_level) { FactoryBot.create(:inventory_level, item: item1, quantity: 10, reorder_level: 4, supplier: 'Tommy Hilfiger') }
    it 'destroys the inventory level' do
      delete "/api/v1/inventory_levels/#{inventory_level.id}", headers: headers
      expect(response).to have_http_status(:no_content)
      expect { inventory_level.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns an error if the inventory level does not exist' do
      delete "/api/v1/inventory_levels/999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end

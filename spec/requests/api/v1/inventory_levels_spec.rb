# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Inventory Levels API', type: :request do
  let!(:category) { FactoryBot.create(:category, name: 'Clothing', description: 'Clothing') }
  let!(:item) { FactoryBot.create(:item, category:, name: 'Tommy Hilfiger T-shirt', price: '24000', selling_price: '25000', reorder_level: 4, size: 'L', color: 'Black') }
  let!(:item1) { FactoryBot.create(:item, category:, name: 'Tommy H T-shirt', price: '25000', selling_price: '25000', size: 'M', reorder_level: 4, color: 'Black') }
  let(:user) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Store Manager', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
  let(:headers) { authenticated_headers(user) }

  before do
    FactoryBot.create(:inventory_level, item:, quantity: 10, supplier: 'Tommy Hilfiger')
  end

  describe 'GET /api/v1/inventory_levels' do
    context 'given parameters' do
      it 'returns a list of inventory levels with pagination' do
        get '/api/v1/inventory_levels', params: { page: 1, per_page: 1 }, headers: headers
        expect(response).to have_http_status(:success)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key('inventory_levels')
        expect(parsed_response).to have_key('total')
        expect(parsed_response['inventory_levels']).to be_an(Array)
        expect(parsed_response['inventory_levels'].size).to eq(1)
      end
    end

    context 'given parameters' do
      it 'returns all inventory_levels when pagination ' do
        get '/api/v1/inventory_levels', headers: headers
        expect(response).to have_http_status(:success)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key('inventory_levels')
        expect(parsed_response).to have_key('total')
        expect(parsed_response['inventory_levels']).to be_an(Array)
      end
    end

    context 'search parameter is included in the request' do
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
  end

  describe 'POST /api/v1/items/:item_id/inventory_levels' do
    context 'given valid attributes' do
      it 'creates a new inventory level' do
        inventory_level_params = { quantity: 10, supplier: 'Tommy Hilfiger' }
        post "/api/v1/items/#{item1.id}/inventory_levels", params: { inventory_level: inventory_level_params }, headers: headers
        expect(response).to have_http_status(:created)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['quantity']).to eq(10)
      end
    end

    context 'given invalid attributes' do
      it 'returns errors and unprocessable entity status code' do
        inventory_level_params = { quantity: 'ffff', supplier: 'Tommy Hilfiger' }
        post "/api/v1/items/#{item1.id}/inventory_levels", params: { inventory_level: inventory_level_params }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to be_an(Array)
      end
    end

    context 'inventory level already exists' do
      before do
        FactoryBot.create(:inventory_level, item: item1, quantity: 10, supplier: 'Tommy Hilfiger')
      end
      it 'returns an error message' do
        inventory_level_params = { quantity: 'ffff', supplier: 'Tommy Hilfiger' }
        post "/api/v1/items/#{item1.id}/inventory_levels", params: { inventory_level: inventory_level_params }, headers: headers
        expect(response).to have_http_status(:bad_request)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["error"]).to eq('Inventory level already exists')
      end
    end
  end

  describe 'PUT /api/v1/inventory_levels/:id' do
    let!(:inventory_level) { FactoryBot.create(:inventory_level, item: item1, quantity: 10, supplier: 'Tommy Hilfiger') } 
    context 'given invalid attributes' do
      it 'updates the inventory level' do
        updated_params = { quantity: 15, supplier: 'Updated Supplier' }
        patch "/api/v1/inventory_levels/#{inventory_level.id}", params: { inventory_level: updated_params }, headers: headers
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['quantity']).to eq(15)
      end
    end

    context 'given invalid attributes' do
      it 'returns unprocessable entity status when inventory level attributes are invalid' do
        updated_params = { quantity: 0, supplier: 'Updated Supplier' }
        patch "/api/v1/inventory_levels/#{inventory_level.id}", params: { inventory_level: updated_params }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /api/v1/inventory_levels/:id' do
    let!(:inventory_level) { FactoryBot.create(:inventory_level, item: item1, quantity: 10, supplier: 'Tommy Hilfiger') }
    context 'inventory level exists' do
      it 'destroys the inventory level and returns no_content status code' do
        delete "/api/v1/inventory_levels/#{inventory_level.id}", headers: headers
        expect(response).to have_http_status(:no_content)
        expect { inventory_level.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'given id that does not exists' do
      it 'returns not_found status code' do
        delete "/api/v1/inventory_levels/999", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

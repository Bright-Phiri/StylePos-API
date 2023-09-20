# frozen_string_literal: true

require 'rails_helper'

describe 'Items API', type: :request do
  let(:user) { FactoryBot.create(:employee, first_name: 'test', last_name: 'Doe', user_name: 'Doe', job_title: 'Store Manager', phone_number: '0883498444', email: 'Doe@gmail.com', password: '12345678', password_confirmation: '12345678') }
  let(:headers) { authenticated_headers(user) }
  describe 'GET /items' do
    let!(:category) { FactoryBot.create(:category, name: 'Clothing', description: 'Clothing') }

    before do
      FactoryBot.create(:item, category:, name: 'Tommy Hilfiger T-shirt', price: '24000', size: 'L', color: 'Black', barcode: 'GHGHG85944')
      FactoryBot.create(:item, category:, name: 'Converse Chuck Taylor sneakers', price: '65000', size: 'L', color: 'Black', barcode: 'GHGHG80044')
    end

    it 'returns a list of items with pagination' do
      get '/api/v1/items', params: { page: 1, per_page: 1 }, headers: headers
      expect(response).to have_http_status(:success)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to have_key('items')
      expect(parsed_response).to have_key('total')
      expect(parsed_response['items']).to be_an(Array)
      expect(parsed_response['items'].size).to eq(1)
    end

    it 'returns all items when pagination parameters are not provided' do
      get '/api/v1/items', headers: headers
      expect(response).to have_http_status(:success)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to have_key('items')
      expect(parsed_response).to have_key('total')
      expect(parsed_response['items']).to be_an(Array)
    end

    it 'returns filtered items when search parameter is provided' do
      get '/api/v1/items', params: { search: 'Converse Chuck Taylor sneakers' }, headers: headers
      expect(response).to have_http_status(:success)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to have_key('items')
      expect(parsed_response).to have_key('total')
      expect(parsed_response['items']).to be_an(Array)
      expect(parsed_response['items'].size).to eq(1)
    end
  end

  describe 'GET /api/v1/categories/:category_id/items/:id' do
    let!(:category) { FactoryBot.create(:category, name: 'Clothing', description: 'Clothing') }
    let!(:item) { FactoryBot.create(:item, category:, name: 'Example Item', color: 'Blue', size: 'M', price: 100.0, barcode: '1234567890') }

    it 'retrieves a single item by ID' do
      get "/api/v1/categories/#{category.id}/items/#{item.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['name']).to eq('Example Item')
      expect(parsed_response['color']).to eq('Blue')
    end
  end

  describe 'POST /api/v1/items' do
    let!(:category) { FactoryBot.create(:category, name: 'Kids', description: 'Kids') }
    it 'creates a new item' do
      post '/api/v1/items', params: { item: { category_id: category.id, name: 'Kids', color: 'Blue', size: 'M', price: '100.0' } }, headers: headers
      expect(response).to have_http_status(:created)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to have_key('name')
      expect(parsed_response['name']).to eq('Kids')
      created_item = Item.find_by(name: 'Kids')
      expect(created_item).not_to be_nil
    end

    it 'returns an error when the category does not exist' do
      post '/api/v1/items', params: {
        item: {
          category_id: 999, # Category doesn't exist
          name: 'New Item',
          color: 'Red',
          size: 'L',
          price: 50.0
        }
      }, headers: headers
      expect(response).to have_http_status(:not_found)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['error']).to include("Couldn't find Category with 'id'=999")
    end
  end

  describe 'PUT /api/v1/categories/:category_id/items/:id' do
    let!(:category) { FactoryBot.create(:category, name: 'Clothing', description: 'Clothing') }
    let!(:item) { FactoryBot.create(:item, category:, name: 'Tommy Hilfiger T-shirt', price: '24000', size: 'L', color: 'Black', barcode: 'GHGHG85944') }

    it 'updates an item' do
      new_attributes = { name: 'Tommy Hilfiger T-shirt', price: '24000', size: 'M', color: 'Red' }
      put "/api/v1/categories/#{category.id}/items/#{item.id}", params: { item: new_attributes }, headers: headers
      expect(response).to have_http_status(:success)
      item.reload
      expect(item.size).to eq('M')
      expect(item.color).to eq('Red')
    end

    it 'returns an error when updating with invalid attributes' do
      put "/api/v1/categories/#{category.id}/items/#{item.id}", params: { item: { name: 'Tommy Hilfiger T-shirt', price: '', size: 'M', color: '' } }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      category.reload
      expect(item.size).to eq('L')
      expect(item.color).to eq('Black')
    end
  end

  describe 'DELETE /categories/:id' do
    let!(:category) { FactoryBot.create(:category, name: 'Kids', description: 'Kids') }
    let!(:item) { FactoryBot.create(:item, category:, name: 'Tommy Hilfiger T-shirt', price: '24000', size: 'L', color: 'Black') }
    it 'deletes an item' do
      expect { delete "/api/v1/items/#{item.id}", headers: headers }.to change { Item.count }.from(1).to(0)
      expect(response).to have_http_status(:no_content)
    end
  end
end

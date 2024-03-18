# frozen_string_literal: true

require 'rails_helper'

describe 'Items API', type: :request do
  let(:user) { FactoryBot.create(:employee, first_name: 'test', last_name: 'Doe', user_name: 'Doe', job_title: 'Store Manager', phone_number: '0883498444', email: 'Doe@gmail.com', password: '12345678', password_confirmation: '12345678') }
  let(:headers) { authenticated_headers(user) }
  describe 'GET /items' do
    let!(:category) { FactoryBot.create(:category, name: 'Clothing', description: 'Clothing') }

    before do
      FactoryBot.create(:item, category:, name: 'Tommy Hilfiger T-shirt', price: '24000', selling_price: '25000', size: 'L', color: 'Black', barcode: 'GHGHG85944')
      FactoryBot.create(:item, category:, name: 'Converse Chuck Taylor sneakers', price: '65000', selling_price: '25000', size: 'L', color: 'Black', barcode: 'GHGHG80044')
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

  describe 'GET /api/v1/items/:id' do
    let!(:category) { FactoryBot.create(:category, name: 'Clothing', description: 'Clothing') }
    let!(:item) { FactoryBot.create(:item, category:, name: 'Example Item', color: 'Blue', size: 'M', price: 100.0, selling_price: '25000', barcode: '1234567890') }

    context 'given id that exists' do
      it 'retrieves a single item' do
        get "/api/v1/items/#{item.id}", headers: headers
        expect(response).to have_http_status(:success)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['name']).to eq('Example Item')
        expect(parsed_response['color']).to eq('Blue')
      end
    end

    context 'given id that does not exist' do
      it 'returns not_found status code' do
        get "/api/v1/items/#{item.id}00", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/items' do
    let!(:category) { FactoryBot.create(:category, name: 'Kids', description: 'Kids') }

    context 'given valid attributes' do
      it 'creates a new item' do
        post "/api/v1/categories/#{category.id}/items", params: { item: { category_id: category.id, name: 'Tommy Hilfiger T-shirt', price: '24000', selling_price: 2500, size: 'L', color: 'Black'} }, headers: headers
        expect(response).to have_http_status(:created)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key('name')
        expect(parsed_response['name']).to eq('Tommy Hilfiger T-shirt')
        created_item = Item.find_by(name: 'Tommy Hilfiger T-shirt')
        expect(created_item).not_to be_nil
      end
    end

    context 'given invalid attributes' do
      it 'returns errors and unprocessable_entity status code' do
        post "/api/v1/categories/#{category.id}/items", params: { item: { category_id: category.id, name: '', color: 'Blue', size: 'M', price: 'fhfh', selling_price: '25000' } }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to be_an(Array)
      end
    end

    context 'category does not exist' do
      it 'returns an error and not_found status code' do
        post "/api/v1/categories/#{999}/items", params: {
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
        expect(parsed_response['error']).to include("Record not found")
      end
    end
  end

  describe 'PUT /api/v1/items/:id' do
    let!(:category) { FactoryBot.create(:category, name: 'Clothing', description: 'Clothing') }
    let!(:item) { FactoryBot.create(:item, category:, name: 'Tommy Hilfiger T-shirt', price: '24000', selling_price: '25000', size: 'L', color: 'Black', barcode: 'GHGHG85944') }

    context 'given valid attributes' do
      it 'updates an item' do
        new_attributes = { name: 'Tommy Hilfiger T-shirt', price: '24000', selling_price: '25000', size: 'M', color: 'Red' }
        put "/api/v1/items/#{item.id}", params: { item: new_attributes }, headers: headers
        expect(response).to have_http_status(:success)
        item.reload
        expect(item.size).to eq('M')
        expect(item.color).to eq('Red')
      end
    end

    context 'given invalid attributes' do
      it 'returns an error and unprocessable_entity status code' do
        put "/api/v1/items/#{item.id}", params: { item: { name: 'Tommy Hilfiger T-shirt', price: '', selling_price: '25000', size: 'M', color: '' } }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to be_an(Array)
        category.reload
        expect(item.size).to eq('L')
        expect(item.color).to eq('Black')
      end
    end
  end

  describe 'DELETE /categories/:id' do
    let!(:category) { FactoryBot.create(:category, name: 'Kids', description: 'Kids') }
    let!(:item) { FactoryBot.create(:item, category:, name: 'Tommy Hilfiger T-shirt', price: '24000', selling_price: '25000', size: 'L', color: 'Black') }
    context 'given id that exists' do
      it 'deletes an item' do
        expect { delete "/api/v1/items/#{item.id}", headers: headers }.to change { Item.count }.from(1).to(0)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'given id that does not exist' do
      it 'returns a not_found status code' do
        delete "/api/v1/items/#{item.id}00", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

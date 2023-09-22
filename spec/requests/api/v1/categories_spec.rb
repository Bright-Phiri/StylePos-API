# frozen_string_literal: true

require 'rails_helper'

describe 'Categories API', type: :request do
  let(:user) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Store Manager', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
  let(:headers) { authenticated_headers(user) }

  describe 'GET /categories' do
    before do
      FactoryBot.create(:category, name: 'Clothing', description: 'Clothing')
      FactoryBot.create(:category, name: 'Electronics', description: 'Electronics')
    end
    it 'retuns all categories' do
      get '/api/v1/categories', headers: headers

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe 'GET /categories/:id' do
    let!(:category) { FactoryBot.create(:category, name: 'Clothing', description: 'Clothing') }

    context 'given id that exists' do
      it 'retrieves a single category by ID' do
        get "/api/v1/categories/#{category.id}", headers: headers

        expect(response).to have_http_status(:success)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['name']).to eq('Clothing')
        expect(parsed_response['description']).to eq('Clothing')
      end
    end

    context 'given id that does not exists' do
      it 'returns a not_found status code' do
        get "/api/v1/categories/#{category.id}00", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /categories/show_items/:id' do
    let!(:category) { FactoryBot.create(:category, name: 'Clothing', description: 'Clothing') }
    let!(:item1) { FactoryBot.create(:item, category:, name: 'Tommy Hilfiger T-shirt', price: '24000', size: 'L', color: 'Black', barcode: 'GHGHG85944') }
    context 'given category id that exists' do
      it 'retrieves items associated with the category' do
        get "/api/v1/categories/show_items/#{category.id}", headers: headers

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key('items')
        expect(parsed_response).to have_key('total')
        expect(parsed_response['items']).to be_an(Array)
        expect(parsed_response['items'].size).to eq(1) # Assuming there are two items
      end
    end

    context 'given category id that does not exists' do
      it 'returns not_found status code' do
        get "/api/v1/categories/show_items/#{category.id}00", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /categories' do
    context 'given valid attributes' do
      it 'creates a new category' do
        expect {
          post '/api/v1/categories', params: { category: { name: 'Cosmetics', description: 'Cosmetics' } }, headers: headers
        }.to change { Category.count }.from(0).to(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'given invalid attributes' do
      it 'returns unprocessable_entity status code and errors' do
        expect do
          post '/api/v1/categories', params: { category: { name: '', description: 'Cosmetics' } }, headers: headers 
        end.not_to change { Category.count }
        expect(response).to have_http_status(:unprocessable_entity)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to be_an(Array)
      end
    end
  end

  describe 'PUT /categories/:id' do
    let!(:category) { FactoryBot.create(:category, name: 'Clothing', description: 'Clothing') }
    context 'given valid attributes' do
      it 'updates category' do
        new_attributes = { name: 'Toys', description: 'Toys' }
        put "/api/v1/categories/#{category.id}", params: { category: new_attributes }, headers: headers
        expect(response).to have_http_status(:success)
        category.reload
        expect(category.name).to eq('Toys')
        expect(category.description).to eq('Toys')
      end
    end

    context 'given invalid attributes' do
      it 'returns unprocessable entity status and errors' do
        put "/api/v1/categories/#{category.id}", params: { category: { name: '', description: '' } }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        category.reload
        expect(category.name).to eq('Clothing')
        expect(category.description).to eq('Clothing')
        expect(JSON.parse(response.body)).to be_an(Array)
        expect(JSON.parse(response.body)[0]).to eq("Name can\'t be blank")
      end
    end
  end

  describe 'DELETE /categories/:id' do
    let!(:category) { FactoryBot.create(:category, name: 'Clothing', description: 'Clothing') }
    context 'given id that exists' do
      it 'deletes a category' do
        expect { delete "/api/v1/categories/#{category.id}", headers: headers }.to change { Category.count }.from(1).to(0)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'given id that does not exists' do
      it 'returns not_found status code' do
        delete "/api/v1/categories/#{category.id}00", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

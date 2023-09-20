# frozen_string_literal: true

require 'rails_helper'

describe 'Customers API', type: :request do
  let!(:customer) { FactoryBot.create(:customer, name: 'John', phone_number: '0993498444') }
  let!(:employee) { FactoryBot.create(:employee, first_name: 'Jane', last_name: 'Smith', user_name: 'janesmith', job_title: 'Cashier', phone_number: '0993499444', email: 'janesmith@gmail.com', password: '12345678', password_confirmation: '12345678') }
  let(:headers) { authenticated_headers(employee) }

  describe 'GET /customers' do
    let!(:customer) { FactoryBot.create(:customer, name: 'John', phone_number: '0993498444') }
    it 'returns a list of all customers' do
      get '/api/v1/customers', headers: headers
      expect(response).to have_http_status(:success)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to be_an(Array)
      expect(parsed_response.size).to eq(1)
    end
  end

  describe 'GET /customers/:id' do
    it 'returns a single employee using ID' do
      get "/api/v1/customers/#{customer.id}", headers: headers
      parsed_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_response['id']).to eq(customer.id)
    end
  end

  describe 'POST /customers' do
    context 'when valid data is provided' do
      it 'saves a customer' do
        customer_params = { name: 'Mike', phone_number: '0883490444' }
        expect {
          post '/api/v1/customers', params: { customer: customer_params }, headers: headers
        }.to change { Customer.count }.from(1).to(2)
        expect(response).to have_http_status(:created)
      end
    end

    context 'when invalid data is provided' do
      it 'it returns unprocessable entity status code' do
        customer_params = { name: 'Mike', phone_number: '99999' }
        expect {
          post '/api/v1/customers/', params: { customer: customer_params }, headers: headers
        }.not_to change(Customer, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT /customers/:id' do
    context 'when valid data is provided' do
      it 'updates a customer' do
        new_params = { name: 'Mike', phone_number: '0883490444' }
        put "/api/v1/customers/#{customer.id}", params: { customer: new_params }, headers: headers
        expect(response).to have_http_status(:ok)
        customer.reload
        expect(customer.name).to eq('Mike')
        expect(customer.phone_number).to eq('0883490444')
      end
    end

    context 'when invalid data is provided' do
      it 'it returns unprocessable entity status code' do
        new_params = { name: 'Mike', phone_number: '99999' }
        put "/api/v1/customers/#{customer.id}", params: { customer: new_params }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        customer.reload
        expect(customer.name).to eq('John')
      end
    end
  end

  describe 'DELETE /customers/:id' do
    it 'deletes a customer' do
      delete "/api/v1/customers/#{customer.id}", headers: headers
      expect(response).to have_http_status(:no_content)
      expect(Customer.count).to eq(0)
    end
  end
end

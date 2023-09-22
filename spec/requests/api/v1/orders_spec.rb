# frozen_string_literal: true

require 'rails_helper'

describe 'Orders API', type: :request do
  describe 'GET /orders' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
    let!(:order) { FactoryBot.create(:order, employee:) }
    let(:headers) { authenticated_headers(employee) }
    it 'retrives all transactions' do
      get '/api/v1/orders', params: { search: '' }, headers: headers
      expect(response).to have_http_status(:success)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to have_key('orders')
      expect(parsed_response).to have_key('total')
      expect(parsed_response['orders']).to be_an(Array)
      expect(parsed_response['orders'].size).to eq(1)
    end
  end

  describe 'POST /employees/employee_id/orders' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
    let(:headers) { authenticated_headers(employee) }
    context 'employee exists' do
      it 'creates a new order' do
        post "/api/v1/employees/#{employee.id}/orders", headers: headers
        expect(response).to have_http_status(:created)
      end
    end

    context 'employee does not exist' do
      it 'returns not_found status code' do
        post "/api/v1/employees/#{employee.id}00/orders", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /orders/:id' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
    let!(:order) { FactoryBot.create(:order, employee:) }
    let(:headers) { authenticated_headers(employee) }

    context 'given id that exists' do
      it 'retrives a single order using ID' do
        get "/api/v1/orders/#{order.id}", headers: headers
        expect(response).to have_http_status(:ok)
      end
    end

    context 'given id that does not exist' do
      it 'returns not_found status codd' do
        get "/api/v1/orders/999", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /orders/:id' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
    let!(:order) { FactoryBot.create(:order, employee: ) }
    let(:headers) { authenticated_headers(employee) }

    context 'given id that exists' do
      it 'deletes an order using ID' do
        expect{
          delete "/api/v1/orders/#{order.id}", headers: headers
        }.to change { Order.count }.from(1).to(0)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'given id that does not exist' do
      it 'returns a no_content not_found status code' do
        expect do
          delete "/api/v1/orders/#{order.id}0", headers: headers
        end.not_to change { Order.count }
        expect(response).to have_http_status(:not_found)
      end
    end
    
  end
end

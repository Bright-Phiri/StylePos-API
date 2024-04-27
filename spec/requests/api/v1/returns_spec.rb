# frozen_string_literal: true

require 'rails_helper'

describe 'Returns API', type: :request do
  let!(:category) { FactoryBot.create(:category, name: 'Clothing', description: 'Clothing') }
  let!(:item) { FactoryBot.create(:item, category:, name: 'Example Item', color: 'Blue', size: 'M', reorder_level: 4, price: 100.0, selling_price: '25000', barcode: '1234567890') }
  let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
  let!(:order) { FactoryBot.create(:order, employee:) }
  let(:headers) { authenticated_headers(employee) }

  before do
    FactoryBot.create(:inventory_level, item:, quantity: 10, supplier: 'Tommy Hilfiger')
  end

  describe 'GET /returns' do
    it 'retrives all item retuns' do
      post "/api/v1/orders/#{order.id}/line_items", params: { line_item: { item_id: item.id, quantity: 2 } }, headers: headers
      expect(response).to have_http_status(:ok)
      response_body = JSON.parse(response.body)
      order = Order.find(response_body['id'])
      line_item = order.line_items.last

      expect {
        post "/api/v1/orders/#{order.id}/return_item/#{line_item.id}", params: { return: { reason: 'test' } }, headers: headers
      }.to change { Return.count }.from(0).to(1)
      expect(response).to have_http_status(:ok)
      get '/api/v1/returns', headers: headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

  describe 'POST /api/v1/employees/employee_id/orders/order_id/line_items' do
    it 'returns an item' do
      post "/api/v1/orders/#{order.id}/line_items", params: { line_item: { item_id: item.id, quantity: 2 } }, headers: headers
      expect(response).to have_http_status(:ok)
      response_body = JSON.parse(response.body)
      order = Order.find(response_body['id'])
      line_item = order.line_items.last

      expect {
        post "/api/v1/orders/#{order.id}/return_item/#{line_item.id}", params: { return: { reason: 'test' } }, headers: headers
      }.to change { Return.count }.from(0).to(1)
      expect(response).to have_http_status(:ok)
    end
  end
end

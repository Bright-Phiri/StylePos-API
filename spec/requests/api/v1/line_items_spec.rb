# frozen_string_literal: true

require 'rails_helper'

describe 'Line Items API', type: :request do
  let!(:category) { FactoryBot.create(:category, name: 'Clothing', description: 'Clothing') }
  let!(:item) { FactoryBot.create(:item, category:, name: 'Example Item', color: 'Blue', size: 'M', reorder_level: 4, price: 100.0, selling_price: '25000', barcode: '1234567890') }
  let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
  let!(:order) { FactoryBot.create(:order, employee:) }
  let(:user) { FactoryBot.create(:employee, first_name: 'test', last_name: 'Doe', user_name: 'Doe', job_title: 'Store Manager', phone_number: '0883498444', email: 'Doe@gmail.com', password: '12345678', password_confirmation: '12345678') }
  let(:headers) { authenticated_headers(user) }

  before do
    FactoryBot.create(:inventory_level, item:, quantity: 10, supplier: 'Tommy Hilfiger')
  end

  describe 'POST /api/v1/orders/:order_id/line_items' do
    context 'given valid attributes' do
      it 'creates a new line item' do
        post "/api/v1/orders/#{order.id}/line_items", params: { line_item: { item_id: item.id, quantity: 3 } }, headers: headers
        expect(response).to have_http_status(:ok)
      end
    end

    context 'given invalid attributes' do
      it 'returns an error and unprocessable_entity status code' do
        post "/api/v1/orders/#{order.id}/line_items", params: { line_item: { item_id: item.id, quantity: 'ghghgh' } }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to be_an(Array)
      end
    end
  end

  describe 'PUT /api/v1/line_items/:line_item_id' do
    context 'given valid attributes' do
      it 'updates a line item' do
        post "/api/v1/orders/#{order.id}/line_items", params: { line_item: { item_id: item.id, quantity: 2 } }, headers: headers
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        order_id = response_body['id']
        order = Order.find(order_id)
        created_line_item = order.line_items.last
        put "/api/v1/line_items/#{created_line_item.id}", params: { line_item: { quantity: 3 } }, headers: headers
        expect(response).to have_http_status(:ok)
      end

      context 'given invalid attributes' do
        it 'returns an error and unprocessable_entity status code' do
          post "/api/v1/orders/#{order.id}/line_items", params: { line_item: { item_id: item.id, quantity: 2 } }, headers: headers
          expect(response).to have_http_status(:ok)
          response_body = JSON.parse(response.body)
          order_id = response_body['id']
          order = Order.find(order_id)
          created_line_item = order.line_items.last
          put "/api/v1/line_items/#{created_line_item.id}", params: { line_item: { quantity: 'jgjf' } }, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to be_an(Array)
        end
      end
    end
  end

  describe 'PATCH /api/v1/orders/order_id/line_items/apply_discount/line_item_id' do
    context 'given valid discount value' do
      it 'apply discount to line item' do
        post "/api/v1/orders/#{order.id}/line_items", params: { line_item: { item_id: item.id, quantity: 2 } }, headers: headers
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        order = Order.find(response_body['id'])
        line_item = order.line_items.last
        patch "/api/v1/orders/#{order.id}/line_items/apply_discount/#{line_item.id}", params: { line_item: { discount: 20 } }, headers: headers
        cached_order = order.line_items.reload
        expect(response).to have_http_status(:ok)
        expect(cached_order.last.discount).to eq(20)
      end
    end

    context "given invalid discount value" do
      it 'returns an error and unprocessable_entity status code' do
        post "/api/v1/orders/#{order.id}/line_items", params: { line_item: { item_id: item.id, quantity: 2 } }, headers: headers
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        order = Order.find(response_body['id'])
        line_item = order.line_items.last
        patch "/api/v1/orders/#{order.id}/line_items/apply_discount/#{line_item.id}", params: { line_item: { discount: order.total + 200 } }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to be_an(Array)
      end
    end
  end

  describe 'DELETE /api/v1/line_items/line_item_id' do
    context 'given id that does not exist' do
      it 'return a not_found status code' do
        post "/api/v1/orders/#{order.id}/line_items", params: { line_item: { item_id: item.id, quantity: 2 } }, headers: headers
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        order_id = response_body['id']
        order = Order.find(order_id)
        line_item = order.line_items.last
        delete "/api/v1/line_items/#{line_item.id}00", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'given id that exists' do
      it 'Deletes a line item' do
        post "/api/v1/orders/#{order.id}/line_items", params: { line_item: { item_id: item.id, quantity: 2 } }, headers: headers
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        order_id = response_body['id']
        order = Order.find(order_id)
        line_item = order.line_items.last
        delete "/api/v1/line_items/#{line_item.id}", headers: headers
        expect(response).to have_http_status(:ok)
      end
    end
  end
end

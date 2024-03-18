# frozen_string_literal: true

require 'rails_helper'

describe 'Tax Rates API', type: :request do
  describe 'GET /tax_rates' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') } 
    let!(:tax_rate) { FactoryBot.create(:tax_rate, name: 'VAT', rate: 16.5) }
    let(:headers) { authenticated_headers(employee) }
    it 'returns a list of all taxrates' do
      get '/api/v1/tax_rates', headers: headers
      expect(response).to have_http_status(:success)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to be_an(Array)
      expect(parsed_response.size).to eq(1)
    end
  end

  describe 'GET /tax_rates/:id' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
    let!(:tax_rate) { FactoryBot.create(:tax_rate, name: 'VAT', rate: 16.5) }
    let(:headers) { authenticated_headers(employee) }
    it 'returns a single tax rate using ID' do
      get "/api/v1/tax_rates/#{tax_rate.id}", headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /tax_rates' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
    let(:headers) { authenticated_headers(employee) }
    context 'given valid attributes' do
      it 'saves a new tax rate' do
        expect {
          post '/api/v1/tax_rates', params: { tax_rate: { name: 'VAT', rate: 16.5 } }, headers: headers
        }.to change { TaxRate.count }.from(0).to(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'given invalid attributes' do
      it 'returns errors and unprocessable_entity status code' do
        post '/api/v1/tax_rates', params: { tax_rate: { name: 'VAT', rate: 'VAT' } }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to be_an(Array)
      end
    end
  end

  describe 'PUT /tax_rates' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
    let!(:tax_rate) { FactoryBot.create(:tax_rate, name: 'VAT', rate: 16.5) }
    let(:headers) { authenticated_headers(employee) }
    context 'given valid attributes' do
      it 'updates an tax rate' do
        new_attributes = { name: 'vat', rate: 16.5 }
        put "/api/v1/tax_rates/#{tax_rate.id}", params: { tax_rate: new_attributes }, headers: headers
        expect(response).to have_http_status(:ok)
        tax_rate.reload
        expect(tax_rate.name).to eq('vat')
      end
    end

    context 'given invalid attributes' do
      it 'returns an errors and unprocessable_entity status code' do
        put "/api/v1/tax_rates/#{tax_rate.id}", params: { tax_rate: { name: 'VAT', rate: 'vat' } }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /tax_rates' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
    let!(:tax_rate) { FactoryBot.create(:tax_rate, name: 'VAT', rate: 16.5) }
    let(:headers) { authenticated_headers(employee) }

    context 'given id that exists' do
      it 'deteles tax rate record' do
        expect {
          delete "/api/v1/tax_rates/#{tax_rate.id}", headers: headers
        }.to change { TaxRate.count }.from(1).to(0)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'given id that does not exist' do
      it 'returns not_found status code' do
        expect do
          delete "/api/v1/tax_rates/#{tax_rate.id}00", headers: headers
        end.not_to change { TaxRate.count }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

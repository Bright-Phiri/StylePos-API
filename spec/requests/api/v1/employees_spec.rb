# frozen_string_literal: true

require 'rails_helper'

describe 'Employees API', type: :request do
  describe 'GET /employees' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') } 
    let!(:employee1) { FactoryBot.create(:employee, first_name: 'Jane', last_name: 'Smith', user_name: 'janesmith', job_title: 'Cashier', phone_number: '0993499444', email: 'janesmith@gmail.com', password: '12345678', password_confirmation: '12345678') } 
    let(:headers) { authenticated_headers(employee) }
    it 'returns a list of all employees' do
      get '/api/v1/employees', headers: headers
      expect(response).to have_http_status(:success)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to be_an(Array)
      expect(parsed_response.size).to eq(2)
    end
  end

  describe 'GET /employees/:id' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
    let(:headers) { authenticated_headers(employee) }
    it 'returns a single employee using ID' do
      get "/api/v1/employees/#{employee.id}", headers: headers
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['first_name']).to eq('John')
      expect(parsed_response['user_name']).to eq('johndoe')
    end
  end

  describe 'POST /employees' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
    let(:headers) { authenticated_headers(employee) }
    context 'given valid attributes' do
      it 'saves a new employee' do
        expect {
          post '/api/v1/employees', params: { employee: { first_name: 'Bright', last_name: 'Issah', user_name: 'biph', job_title: 'Cashier', phone_number: '0883498444', email: 'bphhe@gmail.com', password: '12345678', password_confirmation: '12345678' } }, headers: headers
        }.to change { Employee.count }.from(1).to(2)
        expect(response).to have_http_status(:created)
      end
    end

    context 'given invalid attributes' do
      it 'returns errors and unprocessable_entity status code' do
        post '/api/v1/employees', params: { employee: { first_name: 'test', last_name: 'test', user_name: 'test', job_title: 'Cashier', phone_number: '099349998444', email: 'gmail.com', password: '12345678', password_confirmation: '12345678' } }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to be_an(Array)
      end
    end
  end

  describe 'PUT /employees' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
    let(:headers) { authenticated_headers(employee) }
    context 'given valid attributes' do
      it 'updates an employee' do
        new_attributes = { first_name: 'test', last_name: 'issah', user_name: 'test', job_title: 'Cashier', phone_number: '0993498444', email: 'test@gmail.com', password: '12345678', password_confirmation: '12345678' }
        put "/api/v1/employees/#{employee.id}", params: { employee: new_attributes }, headers: headers
        expect(response).to have_http_status(:ok)
        employee.reload
        expect(employee.first_name).to eq('test')
        expect(employee.last_name).to eq('issah')
      end
    end

    context 'given invalid attributes' do
      it 'returns an errors and unprocessable_entity status code' do
        put "/api/v1/employees/#{employee.id}", params: { employee: { first_name: 'test', last_name: 'test', user_name: 'test', job_title: 'Cashier', phone_number: '099349998444', email: 'gmail.com', password: '12345678', password_confirmation: '12345678' } }, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '/POST /register' do
    context 'there are no employees' do
      it 'creates a store manager employee' do
        post '/api/v1/employees/register', params: { employee: { first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678' } }
        expect(response).to have_http_status(:created)
        expect(Employee.count).to eq(1)
        expect(Employee.first.job_title).to eq('Store Manager')
      end
    end

    context 'there are existing employees' do
      before do
        FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678')
      end
      it 'returns a forbidden status' do
        post '/api/v1/employees/register', params: { employee: { user_name: 'johndoe', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678' } }
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)['message']).to eq('Access Denied: You do not have the required privileges to complete this action.')
      end
    end
  end

  describe 'POST /employees/disable_user/:id' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
    let(:headers) { authenticated_headers(employee) }
    context 'given id that exists' do
      it 'disables the user' do
        post "/api/v1/employees/disable_user/#{employee.id}", headers: headers
        expect(response).to have_http_status(:ok)
        expect(employee.reload.status).to eq("disabled")
      end
    end

    context 'given id that does not exist' do
      it 'returns not_found status code' do
        post "/api/v1/employees/disable_user/#{employee.id}00", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /employees/activate_user/:id' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
    let(:headers) { authenticated_headers(employee) }

    context 'given id that exists' do
      it 'activates the user' do
        post "/api/v1/employees/activate_user/#{employee.id}", headers: headers
        expect(response).to have_http_status(:ok)
        expect(employee.reload.status).to eq("active")
      end
    end

    context 'given id that does not exist' do
      it 'returns not_found status code' do
        post "/api/v1/employees/activate_user/#{employee.id}00", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /employess' do
    let!(:employee) { FactoryBot.create(:employee, first_name: 'John', last_name: 'Doe', user_name: 'johndoe', job_title: 'Cashier', phone_number: '0993498444', email: 'johndoe@gmail.com', password: '12345678', password_confirmation: '12345678') }
    let(:headers) { authenticated_headers(employee) }

    context 'given id that exists' do
      it 'deteles employee record' do
        expect {
          delete "/api/v1/employees/#{employee.id}", headers: headers
        }.to change { Employee.count }.from(1).to(0)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'given id that does not exist' do
      it 'deteles an employee' do
        expect do
          delete "/api/v1/employees/#{employee.id}00", headers: headers
        end.not_to change { Employee.count }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

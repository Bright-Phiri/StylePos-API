# frozen_string_literal: true

require 'rails_helper'

describe 'Authentication API', type: :request do
  let!(:employee) { FactoryBot.create(:employee, first_name: 'ff', last_name: 'Doe', user_name: 'bright', job_title: 'Store Manager', phone_number: '0993098441', email: 'ff@gmail.com', status: 0, password: '12345678', password_confirmation: '12345678') }
  describe 'POST /api/v1/authentication/login' do
    context 'given valid credentials' do
      it 'returns a token and user data' do
        post '/api/v1/authentication/login', params: { user_name: 'bright', password: '12345678' }

        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(parsed_response['token']).to be_present
        expect(parsed_response['user']['id']).to eq(employee.id)
        expect(parsed_response['user']['user_name']).to eq('bright')
      end
    end

    context 'the user is disabled' do
      it 'returns a locked status' do
        employee.update(status: 1)
        post '/api/v1/authentication/login', params: { user_name: 'bright', password: '12345678' }

        expect(response).to have_http_status(:locked)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['message']).to eq('User account disabled')
      end
    end

    context 'given invalid credentials' do
      it 'returns an unauthorized status' do
        post '/api/v1/authentication/login', params: { user_name: 'bright', password: 'invalid_password' }

        expect(response).to have_http_status(:unauthorized)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('Invalid username or password')
      end
    end

    context 'username is does not exist' do
      it 'returns a not_found status code and error message' do
        post '/api/v1/authentication/login', params: { user_name: 'nonexistent_user', password: '12345678' }

        expect(response).to have_http_status(:not_found)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('Username not found')
      end
    end

    context 'there are no user accounts' do
      it 'returns a not_found status code and error message' do
        Employee.destroy_all
        post '/api/v1/authentication/login', params: { user_name: 'bright', password: '12345678' }

        expect(response).to have_http_status(:not_found)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('No user account found')
      end
    end
  end
end

# frozen_string_literal: true

module AuthenticationHelper
  def authenticated_headers(user)
    token = JWT.encode({ user_id: user.id }, Rails.application.secrets.secret_key_base, 'HS256')
    { 'Authorization' => "Bearer #{token}" }
  end
end

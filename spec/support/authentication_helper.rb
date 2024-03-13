# frozen_string_literal: true

module AuthenticationHelper
  def authenticated_headers(user)
    token = JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base, 'HS256')
    { 'Authorization' => "Bearer #{token}" }
  end
end

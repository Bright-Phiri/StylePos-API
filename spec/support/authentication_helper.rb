# frozen_string_literal: true

module AuthenticationHelper
  def authenticated_headers(user)
    token = JWT.encode({ user_id: user.id, exp: 1.hour.from_now.to_i }, Rails.application.secrets.secret_key_base, 'HS256')
    { 'Authorization' => "Bearer #{token}" }
  end
end

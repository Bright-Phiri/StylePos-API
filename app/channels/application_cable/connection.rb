# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
  #   identified_by :current_user

  #   def connect
  #     self.current_user = find_verified_user
  #   end

  #   private

  #   def find_verified_user
  #     token = request.params[:token]

  #     if token.present?
  #       decoded_token = ApplicationController.new.decode_action_cable_token("Bearer #{token}")
  #       user_id = decoded_token[0]['user_id']
  #       return Employee.find_by(id: user_id) if user_id
  #     end

  #     reject_unauthorized_connection
  #   end
  end
end

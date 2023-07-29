# frozen_string_literal: true

class CustomerDisplayChannel < ApplicationCable::Channel
  def subscribed
    stream_from "customer_display_channel"
  end

  def unsubscribed
    stop_all_streams
  end

  on_subscribe do
    DashboardBroadcastJob.perform_later('refresh_dashbaord')
  end
end

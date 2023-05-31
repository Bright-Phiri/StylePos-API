# frozen_string_literal: true

class DashboardChannel < ApplicationCable::Channel
  def subscribed
    stream_from "dashboard_channel"
  end

  def unsubscribed
    stop_all_streams
  end

  on_subscribe do
    DashboardBroadcastJob.perform_later('refresh_dashbaord')
  end
end

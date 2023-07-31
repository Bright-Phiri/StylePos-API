# frozen_string_literal: true

class TransactionBroadcastJob < ApplicationJob
  queue_as :transaction_broadcast

  def perform(transaction)
    txn = OrderRepresenter.new(transaction).as_json
    ActionCable.server.broadcast('customer_display_channel', { transaction: txn.to_json })
  end
end

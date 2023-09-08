# frozen_string_literal: true

class BroadcastTransactionJob < ApplicationJob
  queue_as :transaction_broadcast

  discard_on ActiveJob::DeserializationError

  def perform(transaction)
    txn = OrderRepresenter.new(transaction).as_json
    ActionCable.server.broadcast('customer_display_channel', { transaction: txn.to_json })
  end
end

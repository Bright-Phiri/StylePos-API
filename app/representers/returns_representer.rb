# frozen_string_literal: true

class ReturnsRepresenter
  def initialize(returns)
    @returns = returns
  end

  def as_json
    returns.map do |return_item|
      {
        id: return_item.id,
        order: return_item.order_id,
        item: return_item.item.name,
        reason: return_item.reason,
        refund_amount: return_item.refund_amount,
        return_date: return_item.formatted_created_at
      }
    end
  end

  private

  attr_reader :returns
end

FactoryBot.define do
  factory :received_item do
    item { nil }
    quantity { 1 }
    batch_number { "MyString" }
    supplier { "MyString" }
    cost_price { "9.99" }
    selling_price { "9.99" }
    stock_value { "9.99" }
  end
end

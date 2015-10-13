json.array!(@orders) do |order|
  json.extract! order, :id, :stock_id, :type, :quantity, :price
  json.url order_url(order, format: :json)
end

json.array!(@stocks) do |stock|
  json.extract! stock, :id
  json.url stock_url(stock, format: :json)
end

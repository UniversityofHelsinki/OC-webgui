json.array!(@testis) do |testis|
  json.extract! testis, :id, :name, :city, :age
  json.url testis_url(testis, format: :json)
end

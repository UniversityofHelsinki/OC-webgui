json.array!(@contacts) do |contact|
  json.extract! contact, :answered, :call_ended, :handling_ended
end

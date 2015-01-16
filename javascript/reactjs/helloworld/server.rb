require 'sinatra'
require 'json'

comments = [
  { author: "Pete Hunt", text: "This is one comment" },
  { author: "Jordan Walke", text: "This is *author* comment" }
]

get '/comments' do
  content_type :json
  headers({
    "Access-Control-Request-Methods" => "GET, POST, OPTIONS",
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Headers" => "Accept, Content-Type"
  })
  comments.to_json
end

post '/comments' do
  comment = JSON.parse request.body.read
  p comment
  headers({
    "Access-Control-Request-Methods" => "GET, POST, OPTIONS",
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Headers" => "Accept, Content-Type"
  })
  comments.push(comment)
  comments
end

options '/*' do
  headers({
    "Access-Control-Request-Methods" => "GET, POST, OPTIONS",
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Headers" => "Accept, Content-Type"
  })
end

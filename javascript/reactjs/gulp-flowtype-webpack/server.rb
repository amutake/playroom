require 'sinatra'

get '/bundle.js' do
  send_file File.join(settings.public_folder, 'bundle.js')
end

get '/*' do
  send_file File.join(settings.public_folder, 'index.html')
end

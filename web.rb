require 'sinatra'
require 'stsplatform'
require 'json'

set :public_folder, 'public'
enable :sessions
set :logging, :true

get '/' do
  redirect '/index.html'
end

get '/data' do
  return "You must set your credentials" unless session.has_key?("key_id")
  response =  sts_data_resource.get({'beforeE':1}).data
  return response.to_json
end

post '/data' do
  return "You must set your credentials" unless session.has_key?("key_id")
  code = sts_data_resource.post({'value':params['value']}).code
  return "Value #{params['value']} sent to wotkit, received code #{code}"
end

post '/auth' do
  session['key_id'] = params['key_id']
  session['key_password'] = params['key_password']
  session['sensor_name'] = params['sensor_name']
  return "Credentials Set"
end

private

  def sts_data_resource
    client = STSPlatform::Client.new(
      {auth:{
          key_id:session['key_id'],
          key_password:session['key_password']
          }
      }
    )
    sensor = STSPlatform::Sensors.new(client,session['sensor_name'])
    return STSPlatform::Data.new(sensor)
  end

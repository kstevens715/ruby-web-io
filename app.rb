require 'sinatra'
require 'redis'

class Db
  def self.redis
    @redis ||= Redis.new
  end
end

get '/gets' do
  content_type :json
  {
    body: Db.redis.get('x')
  }.to_json
end

put '/puts' do
  Db.redis.append('x', request.body.read)
end

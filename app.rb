require 'sinatra'
require 'redis'

class Db
  def self.redis
    @redis ||= Redis.new
  end
end

get '/gets' do
  content_type :json

  start = Integer(request.fetch_header('HTTP_RANGE'))
  key = request.fetch_header('HTTP_KEY')
  content = Db.redis.getrange(key, start, -1)
  {
    body: content.length == 0 ? nil : content
  }.to_json
end

put '/puts' do
  key = request.fetch_header('HTTP_KEY')
  Db.redis.append(key, request.body.read)
end

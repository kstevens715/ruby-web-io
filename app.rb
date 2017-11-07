require 'sinatra'
require 'redis'

class Db
  def self.redis
    @redis ||= Redis.new
  end
end

get '/gets' do
  #TODO: Respond with Content-Range header
  content_type :json

  start = Integer(request.fetch_header('HTTP_RANGE'))
  key = request.fetch_header('HTTP_KEY')
  sep = params['sep']
  content = Db.redis.getrange(key, start, -1)
  sep_index = content.index(sep)
  content = sep_index ? content[0..sep_index] : content
  {
    body: content.length == 0 ? nil : content
  }.to_json
end

put '/puts' do
  key = request.fetch_header('HTTP_KEY')
  Db.redis.append(key, request.body.read)
end

require 'sinatra'
require 'redis'

# Listen on all interfaces in the development environment
set :bind, '0.0.0.0'

class Db
  def self.redis
    @redis ||= Redis.new
  end
end

get '/' do
  File.read("#{__dir__}/lib/views/index.html")
end

get '/gets' do
  #TODO: Respond with Content-Range header
  content_type :json
  key = request.fetch_header('HTTP_KEY')
  sep = params['sep']

  http_range = request.fetch_header('HTTP_RANGE')
  begin_range, end_range = http_range.scan(/bytes=(\d+)-(\d*)/).flatten
  end_range = -1 if end_range == ''

  content = Db.redis.getrange(key, begin_range, end_range)
  sep_index = sep ? content.index(sep) : -1
  content = sep_index ? content[0..sep_index] : content
  {
    body: content.length == 0 ? nil : content
  }.to_json
end

put '/puts' do
  key = request.fetch_header('HTTP_KEY')
  Db.redis.append(key, request.body.read)
end

require 'securerandom'

class RubyWebIO
  attr_reader :key

  def initialize(options = {})
    @connection = options[:connection]
    @cursor = 0
    @key = SecureRandom.hex
  end

  def gets
    end_value = nil

    result = connection.get do |req|
      req.url('/gets')
      #req.headers['Range'] = "bytes=#{@cursor}-#{end_value}"
      req.headers['Key'] = @key
      req.headers['Range'] = @cursor
    end

    JSON.parse(result.body)['body']
  end

  def puts(value)
    value = "#{value}\n"
    @cursor = @cursor + value.length
    connection.put do |req|
      req.url('/puts')
      req.body = value
      req.headers['Key'] = @key
    end
  end

  def rewind
    @cursor = 0
  end

  private

  attr_reader :connection, :cursor
end

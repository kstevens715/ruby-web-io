require 'securerandom'
require 'readable_writable'

class RubyWebIO
  include ReadableWritable

  attr_reader :key

  def initialize(options = {})
    @connection = options[:connection]
    @cursor = 0
    @key = SecureRandom.hex
  end

  def getbyte
    get("\n", @cursor).ord
  end

  def gets(sep = "\n")
    get(sep, nil)
  end

  def puts(value)
    write("#{value}\n")
  end

  def write(value)
    raise IOError, "not opened for writing" if closed_write?

    @cursor = @cursor + value.length
    connection.put do |req|
      req.url('/puts')
      req.body = value
      req.headers['Key'] = @key
    end
  end

  alias << write

  def get(sep, end_value)
    raise IOError, "not opened for reading" if closed_read?

    result = connection.get do |req|
      req.url('/gets', sep: sep)
      req.headers['Range'] = "bytes=#{@cursor}-#{end_value}"
      req.headers['Key'] = @key
    end

    value = JSON.parse(result.body)['body']
    @cursor = @cursor + value.to_s.length
    value
  end

  def rewind
    @cursor = 0
  end

  private

  attr_reader :connection, :cursor
end

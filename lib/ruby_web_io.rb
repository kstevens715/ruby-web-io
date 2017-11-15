require 'faraday'
require 'json'
require 'securerandom'
require_relative 'readable_writable'

class RubyWebIO
  include ReadableWritable

  attr_accessor :pos
  attr_reader :fileno, :key

  def initialize(options = {})
    @key = SecureRandom.hex
    @connection = options.fetch(:connection) do
      #TODO: Get this from an environment variable
      Faraday.new(url: 'http://localhost:4567')
    end
    self.pos = 0
  end

  def getbyte
    char = getc
    char ? char.ord : nil
  end

  def getc
    get("\n", pos)
  end

  def gets(sep = "\n", limit = nil)
    limit = limit ? (pos - 1) + limit : nil

    get(sep, limit)
  end

  def puts(value)
    write("#{value}\n")
  end

  def write(value)
    raise IOError, "not opened for writing" if closed_write?

    connection.put do |req|
      req.url('/puts')
      req.body = value
      req.headers['Key'] = @key
    end

    bytes = value.length
    self.pos = pos + bytes
    bytes
  end

  def <<(value)
    write(value)
    self
  end

  def get(sep, end_value)
    raise IOError, "not opened for reading" if closed_read?

    result = connection.get do |req|
      req.url('/gets', sep: sep)
      req.headers['Range'] = "bytes=#{pos}-#{end_value}"
      req.headers['Key'] = @key
    end

    value = JSON.parse(result.body)['body']
    self.pos = pos + value.to_s.length
    value
  end

  def rewind
    self.pos = 0
  end

  def inspect
    "<#{self.class}: #{key}>"
  end

  def isatty; false; end
  def tty?; false; end
  def sync; true; end

  private

  attr_reader :connection
end

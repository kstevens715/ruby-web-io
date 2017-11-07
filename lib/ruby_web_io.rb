require 'securerandom'

class RubyWebIO
  attr_reader :key

  def initialize(options = {})
    @connection = options[:connection]
    @cursor = 0
    @key = SecureRandom.hex
    @readable = true
    @writable = true
  end

  def gets(sep = "\n")
    raise IOError, "not opened for reading" if closed_read?

    end_value = nil

    result = connection.get do |req|
      req.url('/gets', sep: sep)
      #req.headers['Range'] = "bytes=#{@cursor}-#{end_value}"
      req.headers['Key'] = @key
      req.headers['Range'] = @cursor
    end

    value = JSON.parse(result.body)['body']
    @cursor = @cursor + value.to_s.length
    value
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

  #TODO: Move all close/readable/writable to module
  def close
    close_read
    close_write
  end

  def close_read
    @readable = false
  end

  def close_write
    @writable = false
  end

  def closed_read?
    !@readable
  end

  def closed_write?
    !@writable
  end

  def rewind
    @cursor = 0
  end

  private

  attr_reader :connection, :cursor
end

require 'securerandom'

class RubyWebIO
  attr_reader :key

  def initialize(options = {})
    @connection = options[:connection]
    @key = SecureRandom.hex
  end

  def gets
    JSON.parse(connection.get('/gets').body)['body']
  end

  def puts(value)
    connection.put('/puts', value)
  end

  private

  attr_reader :connection
end

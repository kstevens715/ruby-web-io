require 'minitest/autorun'
require 'redis'

module Minitest
  class Spec
    before do
      redis = Redis.new
      redis.flushall
    end
  end
end

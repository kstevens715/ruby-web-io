require 'minitest/autorun'
require 'redis'
require 'capybara'
require 'capybara/minitest'
require 'capybara/minitest/spec'
require 'capybara/poltergeist'

Capybara.default_driver = :poltergeist

module Minitest
  class Spec
    before do
      redis = Redis.new
      redis.flushall
    end
  end
end

class IntegrationTestCase < Minitest::Spec
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  before do
    Capybara.reset_sessions!
    Capybara.app = Sinatra::Application
  end
end

require_relative 'spec_helper'
require 'faraday'
require_relative '../app'
require_relative '../lib/ruby_web_io'

describe RubyWebIO do
  it 'creates a unique key each time' do
    io = build_web_io

    assert_match /\A\h{32}\Z/, io.key
    refute_match io.key, RubyWebIO.new.key
  end

  it 'can use puts/gets' do
    io = build_web_io
    io = StringIO.new

    io.puts('abc')

    io.gets.must_be_nil
    io.rewind
    io.gets.must_equal "abc\n"
  end

  def build_web_io
    conn = Faraday.new do |b|
      b.adapter :rack, Sinatra::Application
    end

    RubyWebIO.new(connection: conn)
  end
end

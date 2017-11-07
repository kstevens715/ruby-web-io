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

  it 'adds newlines when inputting w/ #puts' do
    io = build_web_io

    io.puts('abc')
    io.puts('def')
    io.rewind

    io.gets.must_equal "abc\n"
    io.gets.must_equal "def\n"
    io.gets.must_be_nil
  end

  it 'does not add newlines when inputting w/ #write or #<<' do
    io = build_web_io

    io.write('abc')
    io << 'def'
    io.rewind

    io.gets.must_equal "abcdef"
    io.gets.must_be_nil
  end

  it 'can get input using a custom separator' do
    io = build_web_io

    io.write('some|pipe|delimited|data')
    io.rewind

    io.gets('|').must_equal 'some|'
    io.gets('|').must_equal 'pipe|'
    io.gets('|').must_equal 'delimited|'
    io.gets('|').must_equal 'data'
  end

  it 'maintains a cursor at the end of input' do
    io = build_web_io

    io.write('abc')

    io.gets.must_be_nil
    io.rewind
    io.gets.must_equal 'abc'
  end

  it 'can be closed' do
    io = build_web_io

    io.write('data')
    io.rewind
    io.close

    io.must_be :closed_read?
    io.must_be :closed_write?

    error = -> do
      io.gets
    end.must_raise IOError
    error.message.must_equal 'not opened for reading'

    error = -> do
      io.write('value')
    end.must_raise IOError
    error.message.must_equal 'not opened for writing'
  end

  it 'can close reading' do
    io = build_web_io

    io.close_read

    io.must_be :closed_read?
    io.wont_be :closed_write?

    error = -> do
      io.gets
    end.must_raise IOError
    error.message.must_equal 'not opened for reading'

    io.write('value')
  end

  it 'can close writing' do
    io = build_web_io

    io.close_write

    io.wont_be :closed_read?
    io.must_be :closed_write?

    error = -> do
      io.write('value')
    end.must_raise IOError
    error.message.must_equal 'not opened for writing'

    io.gets.must_be_nil
  end

  it 'can be used by Logger' do
    require 'logger'
    io = build_web_io

    logger = Logger.new(io)
    logger.info('some info')
    logger.fatal('FATAL!')
    io.rewind

    io.gets.must_match /INFO -- : some info/
    io.gets.must_match /FATAL -- : FATAL!/
  end

  it 'can be used by csv' do
    require 'csv'
    io = build_web_io
    row1 = ['this', 'is', 'a', 'csv', 'row']
    row2 = ['and', 'so', 'is', 'this', 'one']

    csv = CSV.new(io)
    csv << row1
    csv << row2
    csv.rewind

    csv.read.must_equal [row1, row2]
  end

  def build_web_io
    conn = Faraday.new do |b|
      b.adapter :rack, Sinatra::Application
    end

    RubyWebIO.new(connection: conn)
  end
end

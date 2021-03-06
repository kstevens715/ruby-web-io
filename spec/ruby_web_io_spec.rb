require_relative 'spec_helper'
require 'faraday'
require_relative '../app'
require_relative '../lib/ruby_web_io'

describe RubyWebIO do
  it 'creates a unique key each time' do
    io = build_web_io

    io.key.must_match(/\A\h{32}\Z/)
    io.key.wont_equal RubyWebIO.new.key
    io.inspect.must_equal "<RubyWebIO: #{io.key}>"
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

  it 'returns the number of bytes being written' do
    build_web_io.write('abc').must_equal 3
  end

  it 'can chain shovel operators' do
    io = build_web_io

    (io << 'abc' << 'def').must_equal io
    io.rewind

    io.gets.must_equal 'abcdef'
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

  it 'does not blow up when separator is nil' do
    io = build_web_io

    io.write('somedata')
    io.rewind

    io.gets(nil, 1024).must_equal 'somedata'
  end

  it 'can limit the bytes returned' do
    io = build_web_io

    io.write('abcdefjhijklmnopqrstuvwxyz')
    io.rewind

    io.gets("\n", 13).must_equal 'abcdefjhijklm'
  end

  it 'can get a single byte' do
    io = build_web_io

    io.write('abc')
    io.rewind

    io.getbyte.must_equal 97
    io.getbyte.must_equal 98
    io.getbyte.must_equal 99
    io.getbyte.must_be_nil
  end

  it 'can get a single character' do
    io = build_web_io

    io.write('abc')
    io.rewind

    io.getc.must_equal 'a'
    io.getc.must_equal 'b'
    io.getc.must_equal 'c'
    io.getc.must_be_nil
  end

  it 'maintains position at the end of input' do
    io = build_web_io

    io.write('abc')

    io.gets.must_be_nil
    io.rewind
    io.gets.must_equal 'abc'
  end

  it 'exposes the position' do
    io = build_web_io
    io.pos.must_equal 0

    io.puts('abc')
    io.puts('def')

    io.pos.must_equal 8
    io.gets
    io.pos.must_equal 8
    io.rewind
    io.pos.must_equal 0
    io.gets
    io.pos.must_equal 4
    io.gets
    io.pos.must_equal 8
  end

  it 'can set the position' do
    io = build_web_io

    io.puts('abc')
    io.puts('def')

    io.rewind
    io.pos = 5
    io.gets.must_equal "ef\n"
  end

  it 'can be rewinded' do
    io = build_web_io

    io.puts('abc')
    io.gets

    io.rewind.must_equal 0
    io.pos.must_equal 0
  end

  it 'can be closed' do
    io = build_web_io

    io.write('data')
    io.rewind
    io.close

    io.must_be :closed_read?
    io.must_be :closed_write?
    io.must_be :closed?

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
    io.wont_be :closed?

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
    io.wont_be :closed?

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

    io.gets.must_match(/INFO -- : some info/)
    io.gets.must_match(/FATAL -- : FATAL!/)
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

  specify { build_web_io.fileno.must_be_nil }
  specify { build_web_io.wont_be :isatty }
  specify { build_web_io.wont_be :tty? }
  specify { build_web_io.must_be :sync }

  def build_web_io
    conn = Faraday.new do |b|
      b.adapter :rack, Sinatra::Application
    end

    RubyWebIO.new(connection: conn)
  end
end

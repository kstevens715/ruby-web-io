require_relative 'spec_helper'
require 'readable_writable'

describe ReadableWritable do
  it 'starts out as readable and writable' do
    instance = build_readable_writable

    instance.wont_be :closed_read?
    instance.wont_be :closed_write?
    instance.wont_be :closed?
  end

  it 'can be closed for reads' do
    instance = build_readable_writable

    instance.close_read

    instance.must_be :closed_read?
    instance.wont_be :closed_write?
    instance.wont_be :closed?
  end

  it 'can be closed for writes' do
    instance = build_readable_writable

    instance.close_write

    instance.wont_be :closed_read?
    instance.must_be :closed_write?
    instance.wont_be :closed?
  end

  it 'can be closed for both' do
    instance = build_readable_writable

    instance.close

    instance.must_be :closed_read?
    instance.must_be :closed_write?
    instance.must_be :closed?
  end

  def build_readable_writable
    Class.new.tap do |readable_writable|
      readable_writable.include(ReadableWritable)
    end.new
  end
end

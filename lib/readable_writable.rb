#TODO: Moved this code, so now it needs its own tests
#TODO: Come up with a namespace for all things in the gem and move this to that namespace
module ReadableWritable
  def close
    close_read
    close_write
  end

  def close_read
    self.readable = false
  end

  def close_write
    self.writable = false
  end

  def closed_read?
    !readable
  end

  def closed_write?
    !writable
  end

  private

  attr_writer :readable, :writable

  def readable
    if defined?(@readable)
      @readable
    else
      @readable = true
    end
  end

  def writable
    if defined?(@writable)
      @writable
    else
      @writable = true
    end
  end
end

module EventMachine::Zip
  class StreamIO
    # NOTE to help with the async nature of the stream, without it the stream closes before
    # archiving is finished
    include EventMachine::Deferrable

    def initialize(&block)
      @block = block
      @pos = 0
    end

    def tell
      @pos
    end

    def pos
      @pos
    end

    def <<(x)
      @block.call(x.to_s)
      @pos+= x.to_s.bytesize
    end

    def each(&block)
      @block = block
    end


    def size
      pos
    end
  end
end

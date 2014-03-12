require 'uri'

module EventMachine::Zip
  class EntryError < StandardError
    # don't pass GO
  end

  class EntryParser
    attr_reader :path, :name

    def initialize(obj)
      parse(obj)
    end

    private

    def parse(obj)
      case obj
      when Hash
        @path, @name = obj[:path], obj[:name]
      when String
        @path = obj
      end

      if name.nil? || name.empty?
        begin
          _uri = URI.parse(path)
        rescue URI::InvalidURIError
          @path = URI.escape(path)
        end
        @name = File.basename(URI.unescape((_uri||URI.parse(path)).path))
      end
    end
  end

  class Entry
    attr_reader :path, :file_name, :zos

    def initialize(ep, zos)
      @path = ep.path
      @file_name = ep.name
      @zos = zos
    end

    def write!
      @f = Fiber.current
      new_entry = ::Zip::Entry.new '-', file_name
      zos.put_next_entry new_entry
      zip_entry!
      Fiber.yield
    end

    private

    def zip_entry!
      case path
      when /\A(http|https):\/\//
        zip_from_http
      else
        zip_from_file
      end
    end


    # TODO this seems chunky, should we classify?

    def zip_from_file
      @file = File.open path, 'r'
      zip_file = proc do
        begin
          if buff = @file.read_nonblock(1024)
            zos << buff
            ::EM.next_tick(&zip_file)
          end
        rescue EOFError
          @file.close
          @f.resume
        end
      end
      zip_file.call
    end

    def zip_from_http
      @file = ::EM::HttpRequest.new(path).get # TODO connect_timeout: 5, inactivity_timeout: 10

      @file.stream do |chunk|
        zos << chunk
      end

      @file.callback do
        @f.resume
      end

      @file.errback do |err|
        raise EntryError
      end
    end
  end
end

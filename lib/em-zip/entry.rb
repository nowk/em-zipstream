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
      _write
      Fiber.yield
    end

    private

    def _write
      case path
      when /\A(http|https):\/\//
        zip_from_http
      else
        zip_from_file
      end
    end

    def create_entry
      new_entry = ::Zip::Entry.new '-', file_name
      zos.put_next_entry new_entry
    end


    def zip_from_file
      @file = File.open path, 'r'
      create_entry
      zip_file.call
    rescue Errno::ENOENT
      errorize_file!
      ::EM.next_tick { @f.resume }
    end

    def zip_file
      proc do
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
    end


    def zip_from_http
      @file = ::EM::HttpRequest.new(path).get # TODO connect_timeout: 5, inactivity_timeout: 10

      @file.headers do |hash|
        unless hash.status == 200
          errorize_file!
          @file.fail
        else
          create_entry
        end
      end

      @file.stream do |chunk|
        begin
          zos << chunk
        rescue IOError; end
      end

      @file.callback do
        @f.resume
      end

      @file.errback do |err|
        @f.resume
      end
    end


    def errorize_file!
      @file_name << '.error.txt'
      create_entry
      zos << 'This File could not be retrieved or is invalid'
    end
  end
end

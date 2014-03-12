module EventMachine
  module Zip
    class Archive
      include ::EventMachine::Deferrable

      attr_reader :output, :files, :size

      def filename
        output.instance_variable_get('@fileName')
      end

      def file_count
        output.instance_variable_get('@entry_set').size
      end

      def initialize(zip_name, files)
        @zip_name = zip_name
        @files = files.is_a?(Array) ? files : [files]
        @output = output_as(zip_name)
      end

      def create!
        Fiber.new { write_zip }.resume
        self
      end

      def resume!
        write_zip
        self
      end

      def succeed(*args)
        @size = output.instance_variable_get('@output_stream').size

        output.close_buffer
        output.close
        super
      end

      private

      def write_zip
        files.each do |file|
          Entry.new(EntryParser.new(file), output).write!
        end
        succeed
      end

      def output_as(zip_name)
        if zip_name.is_a?(String)
          ::Zip::OutputStream.open zip_name # TODO support `stream` arg
        else
          Output.new zip_name
        end
      end
    end
  end
end

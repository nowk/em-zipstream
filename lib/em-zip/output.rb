module EventMachine::Zip
  class Output < ::Zip::OutputStream
    include EventMachine::Deferrable

    def initialize(io)
      super '-', true
      @output_stream = io
    end

    def io
      @output_stream
    end

    # TODO do I need this?
    def update_local_headers
      nil
    end
  end
end

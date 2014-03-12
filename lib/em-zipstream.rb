require 'rubygems'
require 'eventmachine'
require 'em-http-request'
require 'fiber'
require 'zip'

require 'em-zip'

module EventMachine::Zipstream
  def self.new(zip_name, files)
    ::EventMachine::Zip::Archive.new zip_name, files
  end
end

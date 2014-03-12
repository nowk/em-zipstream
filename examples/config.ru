$LOAD_PATH << './lib'
require 'rubygems'
require 'sinatra'
require 'sinatra/async'

require 'em-zipstream'

class Server < Sinatra::Base
  register Sinatra::Async
  apost '/download/zip' do
    headers "Content-Disposition" => "attachment; filename=download.zip", 
      "Content-Type" => "application/octet-stream"
    output = EventMachine::Zip::StreamIO.new
    body output
    zip = EventMachine::Zipstream.new(output, params['files']).create!
    zip.callback { output.succeed }
  end
end

run Server.new

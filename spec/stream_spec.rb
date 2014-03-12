require 'spec_helper'
require 'sinatra/async'
require 'async_rack_test'

class Server < Sinatra::Base
  register Sinatra::Async
  apost '/download/zip' do
    headers "Content-Disposition" => "attachment; filename=download.zip", 
      "Content-Type" => "application/octet-stream"
    output = EventMachine::Zip::StreamIO.new
    body output
    zip = EventMachine::Zipstream.new(output, params['files']).create!
    zip.callback { output.succeed }
    zip.errback { puts 'foo' }
  end
end

describe 'streamio' do
  include AsyncRackTest::Methods

  def app
    Server.new
  end

  it 'streams a zip' do
    pending
    apost '/download/zip', {files: [File1, File2]}
    expect(last_response.status).to eq 200
  end
end

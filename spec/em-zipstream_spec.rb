require 'spec_helper'
require 'webmock/rspec'

describe EventMachine::Zipstream do
  it 'zips multiple files' do
    EM.run do
      stream = StringIO.new
      zip = EventMachine::Zipstream.new stream, [File1, File2]
      zip.create!
      zip.callback do
        expect(zip.filename).to eq '-' # 'output.zip'
        expect(zip.files).to eq [File1, File2]
        expect(zip.file_count).to eq 2
        expect(zip.size).to eq 378161
        EM.stop
      end
    end
  end

  it 'zips a single file' do
    EM.run do
      stream = StringIO.new
      zip = EventMachine::Zipstream.new stream, File2
      zip.create!
      zip.callback do
        expect(zip.filename).to eq '-'
        expect(zip.files).to eq [File2]
        expect(zip.file_count).to eq 1
        expect(zip.size).to eq 68
        EM.stop
      end
    end
  end

  it 'zips from remote sources' do
    remote_file = 'http://s3.amazonaws.com/ping-em-assets/sample-text-01.txt'
    stub_request(:get, /s3\.amazonaws\.com/).to_return(body: File.read(File1))

    EM.run do
      stream = StringIO.new
      zip = EventMachine::Zipstream.new stream, remote_file
      zip.create!
      zip.callback do
        expect(zip.filename).to eq '-'
        expect(zip.files).to eq [remote_file]
        expect(zip.file_count).to eq 1
        expect(zip.size).to eq 355988
        EM.stop
      end
    end
  end
end

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

  describe 'a bad local file' do
    it "saves a text file with the error in it's place" do
      bad_file = '/a/path/to/bad-file-01'

      EM.run do
        stream = StringIO.new
        zip = EventMachine::Zipstream.new stream, bad_file
        zip.create!
        zip.callback do
          stream.rewind
          temp = ::Tempfile.new 'out.zip'
          temp.write stream.read
          temp.close

          error_file = nil
          ::Zip::File::open(temp.path) do |zio|
            zio.each do |e|
              error_file = {name: e.name, body: e.get_input_stream.read}
            end
          end
          temp.unlink

          expect(error_file).to eq({name: 'bad-file-01.error.txt', body: 'This File could not be retrieved or is invalid'})

          EM.stop
        end
      end
    end
  end

  describe 'a bad remote file' do
    it "saves a text file with the error in it's place" do
      bad_file = 'http://s3.amazonaws.com/ping-em-assets/bad-file-01.mp3'
      stub_request(:get, /s3\.amazonaws\.com/)
        .to_return(body: 'Some kind of error message, maybe?', status: 400)

      EM.run do
        stream = StringIO.new
        zip = EventMachine::Zipstream.new stream, bad_file
        zip.create!
        zip.callback do
          stream.rewind
          temp = ::Tempfile.new 'out.zip'
          temp.write stream.read
          temp.close

          error_file = nil
          ::Zip::File::open(temp.path) do |zio|
            zio.each do |e|
              error_file = {name: e.name, body: e.get_input_stream.read}
            end
          end
          temp.unlink

          expect(error_file).to eq({name: 'bad-file-01.mp3.error.txt', body: 'This File could not be retrieved or is invalid'})

          EM.stop
        end
      end
    end
  end
end

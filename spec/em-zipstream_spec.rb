require 'spec_helper'
require 'webmock/rspec'

shared_examples 'a valid zipstream instance' do |filename, files, count, size|
  it 'creates a zip archive' do
    EM.run do
      stream = StringIO.new
      zip = EventMachine::Zipstream.new stream, file
      zip.create!
      zip.callback do
        expect(zip.filename).to eq filename
        expect(zip.files).to eq files
        expect(zip.file_count).to eq count
        expect(zip.size).to eq size
        stream.close
        EM.stop
      end
    end
  end
end

shared_examples 'a zip with an error file' do
  it "saves a text file with the error in it's place" do
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

        expect(error_file).to eq({name: 'bad-file-01.mp3.error.txt', 
                                  body: 'This File could not be retrieved or is invalid'})

        EM.stop
      end
    end
  end
end

describe EventMachine::Zipstream do
  describe 'zips multiple files' do
    it_behaves_like  'a valid zipstream instance', '-', [File1, File2], 2, 378161 do
      let(:file) { [File1, File2] }
    end
  end

  describe 'zips a single file' do
    it_behaves_like  'a valid zipstream instance', '-', [File2], 1, 68 do
      let(:file) { [File2] }
    end
  end

  describe 'zips from remote sources' do
    file = 'http://s3.amazonaws.com/ping-em-assets/sample-text-01.txt' 

    it_behaves_like  'a valid zipstream instance', '-', [file], 1, 355988 do
      let(:file) { file }
      before do
        stub_request(:get, /s3\.amazonaws\.com/).to_return(body: File.read(File1))
      end
    end
  end

  describe 'a bad local file' do
    it_behaves_like 'a zip with an error file' do
      let(:bad_file) { '/a/path/to/a/bad-file-01.mp3' }
    end
  end

  describe 'a bad remote file' do
    it_behaves_like 'a zip with an error file' do
      let(:bad_file) { 'http://s3.amazonaws.com/ping-em-assets/bad-file-01.mp3' }
      before do
        stub_request(:get, /s3\.amazonaws\.com/)
          .to_return(body: 'Some kind of error message, maybe?', status: 400)
      end
    end
  end
end

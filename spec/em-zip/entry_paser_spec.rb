require 'spec_helper'

describe EventMachine::Zip::EntryParser do
  describe 'hash' do
    subject do
      EM::Zip::EntryParser.new path: '/path/to/file', name: 'filename.txt'
    end

    its(:path) { should eq '/path/to/file' }
    its(:name) { should eq 'filename.txt' }
  end

  describe 'hash', 'without name key' do
    subject do
      EM::Zip::EntryParser.new path: '/path/to/file', name: ''
    end

    its(:path) { should eq '/path/to/file' }
    its(:name) { should eq 'file' }
  end

  describe 'string' do
    subject do
      EM::Zip::EntryParser.new '/path/to/file.txt'
    end

    its(:path) { should eq '/path/to/file.txt' }
    its(:name) { should eq 'file.txt' }
  end

  describe 'uri', 'escaped' do
    let(:uri) { 'https://s3.amazonaws.com/file/Featuring%20Kid%20Cudi%29.mp3?foo=bar&baz=qux' }
    subject do
      EM::Zip::EntryParser.new uri
    end

    its(:path) { should eq uri }
    its(:name) { should eq 'Featuring Kid Cudi).mp3' }
  end

  describe 'uri', 'unescaped' do
    let(:uri) { 'https://s3.amazonaws.com/file/Featuring Kid Cudi).mp3?foo=bar&baz=qux' }
    let(:escaped_uri) { "https://s3.amazonaws.com/file/Featuring%20Kid%20Cudi).mp3?foo=bar&baz=qux" }
    subject do
      EM::Zip::EntryParser.new uri
    end

    its(:path) { should eq escaped_uri }
    its(:name) { should eq 'Featuring Kid Cudi).mp3' }
  end
end



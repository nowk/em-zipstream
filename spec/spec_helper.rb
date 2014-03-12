$LOAD_PATH << './lib'

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test)

require 'em-zipstream'

File1 = File.expand_path('./spec/fixtures/files/sample-text-01.txt')
File2 = File.expand_path('./spec/fixtures/files/sample-text-02.txt')

RSpec.configure do |c|
  c.fail_fast = true
end

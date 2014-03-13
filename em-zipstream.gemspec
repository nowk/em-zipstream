Gem::Specification.new do |s|
  s.name = 'em-zipstream'
  s.version = '0.0.2'
  s.date = '2014-03-12'

  s.summary = "Rubyzip on Eventmachine"
  s.description = "Eventmachine wrapper around Rubyzip"
  s.authors = ["Yung H Kwon"]
  s.email = 'yung.kwon@damncarousel.com'

  s.files = %w(
    lib/em-zipstream.rb
    lib/em-zip.rb
    lib/em-zip/archive.rb
    lib/em-zip/entry.rb
    lib/em-zip/output.rb
    lib/em-zip/stream_io.rb
  )
  s.require_paths = ['lib']

  s.add_dependency('eventmachine', ['~> 1.0'])
  s.add_dependency('em-http-request', ['~> 1.1'])
  s.add_dependency('rubyzip', ['~> 1.1'])

  s.homepage = 'https://github.com/nowk/em-zipstream'
  s.license = 'PRIVATE'
end

spec = Gem::Specification.new do |s|
  s.rubyforge_project = 'net_session'
  s.name = 'net_session'
  s.version = '0.0.1'
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.summary = "Class that enables cookie tracking in Net connections, as well as gzip/deflate and extended post functionality"
  s.description = s.summary
  s.author = 'Jeremy Nicoll'
  s.email = 'jnicoll@gnexp.com'
  s.homepage = 'http://github.com/eltiare/net_session/tree/master'
  s.require_path = 'lib'
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,spec}/**/*")
end

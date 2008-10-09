require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'

begin
  require 'merb-core/version'
  require 'merb-core/tasks/merb_rake_helper'
rescue
  # If we can't load merb, it's not a big deal.
end

spec = eval(File.read('net_session.gemspec'))
Rake::GemPackageTask.new(spec) { |pkg| pkg.gem_spec = spec }

sudo = ((RUBY_PLATFORM =~ /win32|mingw|bccwin|cygwin/) rescue nil) ? '' : ('sudo' unless ENV['SUDOLESS'])

desc "install the plugin locally"
task :install => [:package] do
  sh "#{sudo} gem install pkg/#{spec.name}-#{spec.version} --no-update-sources}"
end

namespace :jruby do

  desc "Run :package and install the resulting .gem with jruby"
  task :install => :package do
    sh "#{sudo} jruby -S gem install #{install_home} pkg/#{NAME}-#{GEM_VERSION}.gem --no-rdoc --no-ri"
  end

end

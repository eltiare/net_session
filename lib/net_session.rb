require 'net/https'
require 'mime/types'
require 'zlib'
require 'stringio'

require 'net_session/cookie_jar'
require 'net_session/net/http_header'
require 'net_session/net/session'
require 'net_session/class_extensions'

# Merb is *not* required for this library - but we'll add some niceties for those
# lucky enough to get to use Merb for their projects... eventually.
if defined?(Merb::Plugins)

  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:net_session] = {
    :chickens => false
  }

  Merb::BootLoader.before_app_loads do
    # require code that must be loaded before the application
  end

  Merb::BootLoader.after_app_loads do
    # code that can be required after the application loads
  end

  Merb::Plugins.add_rakefiles "net_session/merbtasks"
end

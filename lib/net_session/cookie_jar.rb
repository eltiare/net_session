# The CookieJar class is responsible for handling all cookie functionality
class CookieJar < Hash
  attr_reader :expires

  # Basically it's the same as the method update
  def initialize(str_or_hash = nil, defaults = {})
    update(str_or_hash, defaults)
  end

  # The update method takes either a string or a hash.  The string needs to be
  # formatted like a cookie.  Please note that this does not take *all* cookie
  # formats yet, but it takes many.
  def update(str_or_hash, defaults = {})
    case str_or_hash
      when String:
        # Get expires part of cookie and remove it from string
        matches = str_or_hash.match(/expires=([^;]+)/i)
        @expires = DateTime.parse(matches[1]) if matches
        str_or_hash.gsub!(/expires=([^;]+);/i, '')
        #  Split up the string and get the cookies!
        str_or_hash.split(',').each { |cookie|
          cookie = trim(cookie)
          cookie_name = false
          cookie.split(';').each_with_index { |piece, i|
            piece = trim(piece)
            crumb_name, crumb_val = trim(piece.split('=',2))
            crumb_name.downcase! if i > 0

            if i == 0
              cookie_name = crumb_name.downcase
              self[cookie_name] = Cookie.new(crumb_val)
              self[cookie_name]['name'] = crumb_name
            elsif crumb_name == 'secure'
              self[cookie_name].secure = true
            else
              self[cookie_name][crumb_name] = crumb_val
            end
          }
        }
      when Hash:
        # TODO: This really needs to be better.
        begin; @expires = DateTime.parse(str_or_hash.delete(:expires)) if str_or_hash[:expires]; rescue; end
        merge!(str_or_hash)
    end

  end

  # Puts the cookie information out in string format. Will eventually consider
  # expirary and path information, but currently does not.
  def to_s; map { |name, val| "#{val['name']}=#{val}" }.join(','); end

  class InvalidKey < StandardError; end
  protected

  def trim(str) #:nodoc:
    case str
      when Array: str.map {|s| trim(s) }
      when String: str.gsub(%r'(^\s+)|(\s+$)', '')
    end
  end

  class Cookie < String
    attr_accessor :secure

    # "name" is not actually a valid cookie attribute, but we will use it for internal processing.
    VALID_KEYS = ['comment', 'domain', 'max-age', 'path', 'version', 'name']

    def initialize(*)
      @attributes = {}
      super
    end

    def [](key)
      check key
      @attributes[key.downcase]
    end

    def []=(key, val)
      key.downcase!
      check key
      @attributes[key] = val
    end

  protected
    def check(key)
      raise InvalidKey.new("#{key} is not a valid cookie key.") unless VALID_KEYS.include?(key)
    end

  end # class Cookie
end # class CookieJar

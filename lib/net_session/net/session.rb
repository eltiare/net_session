# The Net::Session class was created out of a need for me to access sites
# that required log in and kept session state.  This essentially acts as a
# simple client to keep session states
class Net::Session < Net::HTTP
  class UnknownEncoding < StandardError; end

  attr_accessor :auto_referral, :auto_redirect, :accept_compressed
  attr_reader :last_request, :last_response, :referer_url


  def request(*args) #:nodoc:
    args[0]['cookie'] = (args[0]['cookie'] ? cookies.dup.merge(CookieJar.new(args[0]['cookie'])) : cookies).to_s
    args[0]['referer'] ||= @referer_url if @auto_referral && @referer_url

    set_default_headers(args[0])

    @last_request = args[0]

    res = super

    # Handle content encoding if present.
    res.instance_variable_set(:@body, case res['content-encoding']
      when 'gzip': Zlib::GzipReader.new(StringIO.new(res.body)).read
      when 'deflate'
        begin
          Zlib::Inflate.new.inflate(res.body)
        rescue Zlib::DataError
          Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(res.body)
        end
      else raise UnkownEncoding.new("Page returned unknown encoding: #{res['content-encoding']}")
    end) unless res['content-encoding'].blank?
    res.delete('content-encoding')

    @referer_url = full_url(args[0]) if @auto_referral && res.code.to_i.between?(200, 299)

    cookies.update(res.header['set-cookie'])

    @last_response = res
  end


  # This is included as my version of Ruby (1.8.7) the post method is broken.
  def post(path, data, initheader = nil, dest = nil, &block) #:nodoc:
    res = nil

    req = Post.new(path, initheader); req.set_form_data(data)
    request(req) {|r| r.read_body dest, &block; res = r}

    unless @newimpl
      res.value
      return res, res.body
    end

    res
  end

  # Returns the full url of a path.
  def full_url(req)
    "#{url_base}#{case req;  when String: req; else req.path; end}"
  end

  # Returns the cookies currently set in this object.
  def cookies; @cookies ||= CookieJar.new; end

  # Returns the default headers either set before or in the method
  def default_headers
    @default_headers ||= {}
    {
      'user-agent' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.1) Gecko/2008070206 Firefox/3.0.1',
      'accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'accept-language' => 'en-us,en;q=0.5',
      'accept-charset' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7',
      'keep-alive' =>  300,
      'connection' => 'keep-alive'
    }.each { |k,v|  @default_headers[k] ||= v }
    @default_headers['accept-encoding'] = 'gzip,deflate' if @accept_compressed
    @default_headers
  end

  # Default headers takes a hash.  These headers are set up the same way as
  # usual Net::HTTP requests (hash['accept-encoding'] = 'gzip,deflate')
  # Note that this currently _replaces_ the default headers
  def default_headers=(hash)
    if hash
      raise 'You must pass a hash to default_headers=' unless hash.is_a?(Hash)
      @default_headers = hash
    else
      @default_headers = nil
    end
  end

private

  def url_base
    "http#{'s' if @use_ssl}://#{@address}#{":#{@port}" unless port == 80 or @use_ssl && port == 433}"
  end

  def set_default_headers(req)
    default_headers.each { |key, val| req[key] = val unless req[key] }
  end

end

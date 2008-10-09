class Net::Session < Net::HTTP
  class UnknownEncoding < StandardError; end

  attr_accessor :auto_referral, :auto_redirect, :accept_compressed
  attr_reader :last_request, :last_response, :referer_url

  def request(*args)
    args[0]['cookie'] = (args[0]['cookie'] ? cookies.dup.merge(Eltiare::CookieJar.new(args[0]['cookie'])) : cookies).to_s
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


  # I added this because Ruby 1.8.7's post method was broken.
  def post(path, data, initheader = nil, dest = nil, &block) # :yield: +body_segment+
    res = nil

    req = Post.new(path, initheader); req.set_form_data(data)
    request(req) {|r| r.read_body dest, &block; res = r}

    unless @newimpl
      res.value
      return res, res.body
    end

    res
  end

  def full_url(req)
    "#{url_base}#{case req;  when String: req; else req.path; end}"
  end

  def cookies; @cookies ||= Eltiare::CookieJar.new; end

  def default_headers
    @default_headers ||= {}
    headers = {
      'user-agent' => @default_headers['user_agent'] || 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.1) Gecko/2008070206 Firefox/3.0.1',
      'accept' => @default_headers['accept'] || 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'accept-language' => @default_headers['accept_language'] || 'en-us,en;q=0.5',
      'accept-charset' => @default_headers['accept_charset'] || 'ISO-8859-1,utf-8;q=0.7,*;q=0.7',
      'keep-alive' => @default_headers['keep_alive']|| 300,
      'connection' => @default_headers['connection'] || 'keep-alive'
    }
    headers['accept-encoding'] = 'gzip,deflate' if @accept_compressed
    headers
  end

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

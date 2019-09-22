require "uri"
require "net/http"
require "rest-client"



def url_exist2?(url_string)
  begin
    #RestClient.get url_string
    RestClient::Request.execute(method: :get, url: url_string, timeout: 10)
    true
  rescue RestClient::ExceptionWithResponse => e
    puts e
    false
  rescue Errno::ECONNREFUSED
    false #false if Failed to open TCP connection
  rescue SocketError
    false #false if Failed to open TCP connection
  rescue OpenSSL::SSL::SSLError
    false
  end
end

def url_exist?(url_string)
  url = URI.parse(url_string)
  req = Net::HTTP.new(url.host, url.port)
  req.use_ssl = (url.scheme == 'https')
  path = url.path if url.path.nil?
  res = req.request_head(path || '/')
  if res.kind_of?(Net::HTTPRedirection)
    p "#{url_string} redirecting to #{res['location']}"
    url_exist?(res['location']) # Go after any redirect and make sure you can access the redirected URL
  else
    ! %W(4 5).include?(res.code[0]) # Not from 4xx or 5xx families
  end
rescue Errno::ENOENT
  false #false if can't find the server
rescue Errno::ENOENT
  false #false if can't find the server
rescue URI::InvalidURIError
  false #false if URI is invalid
rescue SocketError
  false #false if Failed to open TCP connection
rescue Errno::ECONNREFUSED
  false #false if Failed to open TCP connection
rescue Net::OpenTimeout
  false #false if execution expired
rescue OpenSSL::SSL::SSLError
  false
end


input_lines = File.open('README.md')
input_lines.each do |line|
  parentheses_content = line.scan(/\(([^()]*)\)/)
  parentheses_content.each do |possible_uri|
    # p possible_uri
    uri = URI.extract(possible_uri.first, /http(s)?/)
    if uri.first
      uri = uri.first
      p "uri: #{uri}"
      p "exists: #{url_exist2? (uri)}"
    end
  end
end
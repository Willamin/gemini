require "openssl"
require "socket"
require "uri"

class Crem::Server
  def start
    puts("listening on gemini://0.0.0.0:1965")

    tcp_server = TCPServer.new("0.0.0.0", 1965)
    ssl_context = OpenSSL::SSL::Context::Server.new
    ssl_context.certificate_chain = "cert.pem"
    ssl_context.private_key = "key.pem"
    ssl_server = OpenSSL::SSL::Server.new(tcp_server, ssl_context)

    while client = ssl_server.accept?
      spawn handle_client(client)
    end
  end

  def handle_client(client)
    client << "20 text/gemini; charset=utf-8\r\nhello world\njust a quick, hard-coded gemini response; more to come"
    client.close
  end
end

class Crem::Gemini::Request
  def initialize(raw : String)
    @uri = URI.parse(raw)
  end
end

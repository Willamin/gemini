require "openssl"
require "socket"
require "uri"

class Crem::Server
  def start
    puts("listening on gemini://0.0.0.0:1965")

    tcp_server = TCPServer.new("0.0.0.0", 1965)
    ssl_context = OpenSSL::SSL::Context::Server.new
    ssl_context.certificate_chain = "openssl.crt"
    ssl_context.private_key = "openssl.key"
    ssl_server = OpenSSL::SSL::Server.new(tcp_server, ssl_context)

    while client = ssl_server.accept?
      spawn handle_client(client)
    end
  end

  def handle_client(client)
    client.puts "hello"
  end
end

class Crem::Gemini::Request
  def initialize(raw : String)
    @uri = URI.parse(raw)
  end
end

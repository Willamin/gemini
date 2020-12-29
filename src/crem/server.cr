require "openssl"
require "socket"
require "uri"

class Crem::Server
  class Config
    property bind_address : String = "0.0.0.0"
    property bind_port : Int32 = 1965
    property cert_chain : String = "cert.pem"
    property private_key : String = "key.pem"

    def self.from_env
      c = Config.new
      c.bind_address = ENV["CREM_ADDRESS"]? || c.bind_address
      c.bind_port = ENV["CREM_PORT"]?.try(&.to_i32) || c.bind_port
      c.cert_chain = ENV["CREM_CERT"]? || c.cert_chain
      c.private_key = ENV["CREM_KEY"]? || c.private_key
      c
    end
  end

  def initialize(@config : Config); end

  def start
    puts("listening on gemini://#{@config.bind_address}:#{@config.bind_port}")
    puts("with cert chain: #{@config.cert_chain}")
    puts("and private key: #{@config.private_key}")

    tcp_server = TCPServer.new(@config.bind_address, @config.bind_port)
    ssl_context = OpenSSL::SSL::Context::Server.new
    ssl_context.certificate_chain = @config.cert_chain
    ssl_context.private_key = @config.private_key
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

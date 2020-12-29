require "openssl"
require "socket"
require "uri"

class Crem::Server
  class Config
    property bind_address : String
    property bind_port : Int32
    property cert_chain : String
    property private_key : String

    def initialize(
      @bind_address,
      @bind_port,
      @cert_chain,
      @private_key
    ); end

    class Builder
      property bind_address : String?
      property bind_port : Int32?
      property cert_chain : String?
      property private_key : String?

      def finish!
        raise "bind_address required when finishing Crem::Server::Config::Builder" unless the_bind_address = @bind_address
        raise "bind_port required when finishing Crem::Server::Config::Builder" unless the_bind_port = @bind_port
        raise "cert_chain required when finishing Crem::Server::Config::Builder" unless the_cert_chain = @cert_chain
        raise "private_key required when finishing Crem::Server::Config::Builder" unless the_private_key = @private_key
        Config.new(
          the_bind_address,
          the_bind_port,
          the_cert_chain,
          the_private_key,
        )
      end
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

  def handle_client(client : OpenSSL::SSL::Socket::Server)
    request = client.gets
    puts("#{Time.utc} #{request}")
    client.puts(<<-GEM
      20 text/gemini
      # Welcome

      Hi, I'm Will.

      I'm writing a Gemini server in Crystal-lang and I'm hosting what I have in-progress here.

      Currently I've implemented:
      * TLS connection
      * TCP server
      * recognizing the requested url (see below)
      * logging datetime + requested url

      you requested:
      ```
      #{request}
      ```

      Thanks for stopping by! I'll be adding further support for the Gemini protocol over the next few days, hopefully.
      GEM
    )
    client.flush
    client.close
  end
end

class Crem::Gemini::Request
  def initialize(raw : String)
    @uri = URI.parse(raw)
  end
end

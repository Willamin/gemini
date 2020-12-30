class Crem::Gemini::Client
  def self.open
    yield self.new
  end

  def fetch(uri) : Crem::Gemini::Response
    host = URI.parse(uri).hostname.not_nil!
    socket = TCPSocket.new(host, 1965)
    context = OpenSSL::SSL::Context::Client.new
    context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
    ssl_socket = OpenSSL::SSL::Socket::Client.new(socket, context, hostname: host)

    ssl_socket << "#{uri}\r\n"
    ssl_socket.flush
    Crem::Gemini::Response.parse(ssl_socket)
  end
end

module Crem::Gemini
  abstract class Response
    def self.parse(io : IO) : Response
      case io.gets(2).try &.to_i32
      when 20 then Success.new(io)
      else         raise "invalid"
      end
    end

    class Success < Response
      getter io : IO

      def initialize(@io); end
    end
  end
end

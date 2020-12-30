class Gemini::Client
  def self.open
    yield self.new
  end

  def fetch(uri) : Gemini::Response
    host = URI.parse(uri).hostname.not_nil!
    socket = TCPSocket.new(host, 1965)
    context = OpenSSL::SSL::Context::Client.new
    context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
    ssl_socket = OpenSSL::SSL::Socket::Client.new(socket, context, hostname: host)

    ssl_socket << "#{uri}\r\n"
    ssl_socket.flush
    Gemini::Response.parse(ssl_socket)
  end
end

module Gemini
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

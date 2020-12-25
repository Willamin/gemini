require "socket"
require "openssl"

require "./gemini/*"

class String
  def puts(io : IO = STDOUT); io.puts(self); end
end

class Object
  def pp(io : IO = STDOUT); io.puts(self.inspect); end
  def pipe(); yield self; end
end

module Crem
  VERSION = "0.1.0"

  module Gemini
    VERSION = "0.14.3"
    VERSION_DATE = "2020-11-29"
  end
end

class Crem::REPL
  @verbose = false

  def verbose_puts(value)
    if @verbose
      puts(value)
    end
  end

  def start
    loop do
      print("uri to fetch: ")
      STDIN.gets
        .try(&.strip)
        .try { |i| eval(i) }
        .pipe { |x| x || "<no response>" }
        .puts
      puts("\n-------\n")
    end
  end

  def eval(uri : String, host : String? = nil)
    verbose_puts("establishing TLS handshake")
    host = host || URI.parse(uri).hostname.not_nil!
    socket = TCPSocket.new(host, 1965)
    context = OpenSSL::SSL::Context::Client.new
    context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
    ssl_socket = OpenSSL::SSL::Socket::Client.new(socket, context, hostname: host)

    verbose_puts("making gemini request")
    ssl_socket << "#{uri}\r\n"
    ssl_socket.flush
    ssl_socket.gets_to_end
  end
end

case ARGV[0]?
when "repl" then Crem::REPL.new.start
else STDERR.puts("usage: #{PROGRAM_NAME} repl"); exit(1)
end

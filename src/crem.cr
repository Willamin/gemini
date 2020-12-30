require "mime"
require "socket"
require "openssl"
require "option_parser"

require "./gemini/*"
require "./crem/*"

class String
  def puts(io : IO = STDOUT)
    io.puts(self)
  end
end

class Object
  def pp(io : IO = STDOUT)
    io.puts(self.inspect)
  end

  def pipe
    yield self
  end
end

module Crem
  VERSION = "0.1.0"

  module Gemini
    VERSION      = "0.14.3"
    VERSION_DATE = "2020-11-29"
  end
end

command = :none

server_config = Crem::Server::Config::Builder.new.tap do |config|
  # set defaults
  config.bind_address = "0.0.0.0"
  config.bind_port = 1965

  # override with ENV
  if env_value = ENV["CREM_ADDRESS"]?
    config.bind_address = env_value
  end
  if env_value = ENV["CREM_PORT"]?.try(&.to_i32)
    config.bind_port = env_value
  end
  if env_value = ENV["CREM_CERT"]?
    config.cert_chain = env_value
  end
  if env_value = ENV["CREM_KEY"]?
    config.private_key = env_value
  end
end

parser = OptionParser.new do |parser|
  parser.banner = "Usage: crem COMMAND [options]"
  parser.on("repl", "start a simple client repl") do
    command = :repl
    parser.banner = "Usage: crem repl"
  end
  parser.on("server", "start a simple gemini server") do
    command = :server
    parser.banner = "Usage: crem server [options]"
    parser.on("--cert=FILE", "Specify the certificate chain file") { |file| server_config.cert_chain = file }
    parser.on("--key=FILE", "Specify the private key file") { |file| server_config.private_key = file }
  end
  parser.on("help", "show this help") do
    command = :help
  end
end
parser.parse

case command
when :repl then Crem::REPL.new.start
when :help then puts(parser); exit(0)
when :server
  begin
    MIME.register(".gmi", "text/gemini")

    server = Crem::Gemini::Server.new([
      Crem::Gemini::Server::InternalRedirectHandler.new({"/" => "gemini.gmi"}),
      Crem::Gemini::Server::StaticHandler.new("."),
    ])

    server.certificate_chain = server_config.cert_chain
    server.private_key = server_config.private_key

    puts("listening on gemini://#{server.address}:#{server.port}")
    server.listen
  rescue e
    puts(e.message)
    exit(1)
  end
else puts(parser); exit(1)
end

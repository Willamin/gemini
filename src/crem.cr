require "socket"
require "openssl"

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

case ARGV[0]?
when "repl" then Crem::REPL.new.start
when "server"
  config = Crem::Server::Config.from_env
  Crem::Server.new(config).start
else
  STDERR.puts(<<-USAGE
  usage: #{PROGRAM_NAME} CMD

  commands:
    repl                  start a simple client repl
    server                start a simple gemini server
  USAGE
  )
  exit(1)
end

require "socket"
require "openssl"

require "./gemini/*"

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

class Crem::REPL
  @history = [] of String

  def start
    Signal::INT.trap do
      puts("~~ see you! ~~")
      exit(0)
    end

    Crem::Gemini::Client.open do |client|
      loop do
        print("uri to fetch: ")
        if line = STDIN.gets
          @history << line
          response = client.fetch(line.strip)
          case response
          when Gemini::Response::Success then puts("success")
          end
          puts("\n-------\n")
        end
      end
    end
  end
end

case ARGV[0]?
when "repl" then Crem::REPL.new.start
else             STDERR.puts("usage: #{PROGRAM_NAME} repl"); exit(1)
end

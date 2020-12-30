class Crem::Gemini::Server
  property address = "0.0.0.0"
  property port = 1965
  property certificate_chain : String?
  property private_key : String?

  def self.new(&handler : Crem::Gemini::Server::Handler::HandlerProc) : self
    new(handler)
  end

  def self.new(handlers : Array(Crem::Gemini::Server::Handler), &handler : Crem::Gemini::Server::Handler::HandlerProc) : self
    new(self.build_middleware(handlers, handler))
  end

  def self.new(handlers : Array(Crem::Gemini::Server::Handler)) : self
    new(self.build_middleware(handlers))
  end

  def initialize(handler : Crem::Gemini::Server::Handler | Crem::Gemini::Server::Handler::HandlerProc)
    @handler = handler
  end

  def start_underlying_servers
    tcp_server = TCPServer.new(@address, @port)
    ssl_context = OpenSSL::SSL::Context::Server.new
    ssl_context.certificate_chain = @certificate_chain.not_nil!
    ssl_context.private_key = @private_key.not_nil!
    ssl_server = OpenSSL::SSL::Server.new(tcp_server, ssl_context)
  end

  def listen
    ssl_server = start_underlying_servers
    while conn = ssl_server.accept?
      spawn handle_connection(conn)
    end
  end

  def handle_connection(conn)
    raw_request = conn.gets.not_nil!
    ctx = Context.new(Context::Request.new(raw_request))
    @handler.call(ctx)
    conn.print(ctx.response.full)
    conn.close
  end

  def build_middleware(handlers, last_handler : (Context ->)? = nil)
    raise ArgumentError.new "You must specify at least one Gemini Handler." if handlers.empty?
    0.upto(handlers.size - 2) { |i| handlers[i].next = handlers[i + 1] }
    handlers.last.next = last_handler if last_handler
    handlers.first
  end
end

class Crem::Gemini::Server::Context
  getter request : Request
  getter response : Response = Response.new

  def initialize(@request); end
end

class Crem::Gemini::Server::Context::Request
  property uri

  def initialize(raw : String)
    @uri = URI.parse(raw)
  end
end

class Crem::Gemini::Server::Context::Response
  property status : Crem::Gemini::Status = Crem::Gemini::Status::TemporaryFailure
  property content_type : String?
  getter body : String = ""

  def print(printable_thing)
    @body += printable_thing
  end

  def full
    String.build do |s|
      s << status.to_i32.to_s
      if ct = content_type
        s << " "
        s << ct
      end
      s << "\r\n"
      s << @body
    end
  end
end

module Crem::Gemini::Server::Handler
  property next : Handler | HandlerProc | Nil

  abstract def call(context : Crem::Gemini::Server::Context)

  def call_next(context : Crem::Gemini::Server::Context)
    if next_handler = @next
      next_handler.call(context)
    else
      raise
      # context.response.respond_with_status(:not_found)
    end
  end

  alias HandlerProc = Crem::Gemini::Server::Context ->
end

class CustomHandler
  include Crem::Gemini::Server::Handler

  def call(context)
    puts "Doing some stuff"
    # call_next(context)
  end
end

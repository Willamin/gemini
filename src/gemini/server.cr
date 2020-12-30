class Gemini::Server
  property address = "0.0.0.0"
  property port = 1965
  property certificate_chain : String?
  property private_key : String?

  class MissingCertificateChain < Exception; end

  class MissingPrivateKey < Exception; end

  def self.new(&handler : Gemini::Server::Handler::HandlerProc) : self
    new(handler)
  end

  def self.new(handlers : Array(Gemini::Server::Handler), &handler : Gemini::Server::Handler::HandlerProc) : self
    new(self.build_middleware(handlers, handler))
  end

  def self.new(handlers : Array(Gemini::Server::Handler)) : self
    new(self.build_middleware(handlers))
  end

  def initialize(handler : Gemini::Server::Handler | Gemini::Server::Handler::HandlerProc)
    @handler = handler
  end

  def start_underlying_servers
    ssl_context = OpenSSL::SSL::Context::Server.new

    unless cert_chain = @certificate_chain
      raise MissingCertificateChain.new
    end
    unless priv_key = @private_key
      raise MissingPrivateKey.new
    end

    ssl_context.certificate_chain = cert_chain
    ssl_context.private_key = priv_key

    tcp_server = TCPServer.new(@address, @port)
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

  def self.build_middleware(handlers, last_handler : (Context ->)? = nil)
    raise ArgumentError.new "You must specify at least one Gemini Handler." if handlers.empty?
    0.upto(handlers.size - 2) { |i| handlers[i].next = handlers[i + 1] }
    handlers.last.next = last_handler if last_handler
    handlers.first
  end
end

require "./server/*"

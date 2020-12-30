module Gemini::Server::Handler
  property next : Handler | HandlerProc | Nil

  abstract def call(context : Gemini::Server::Context)

  def call_next(context : Gemini::Server::Context)
    if next_handler = @next
      next_handler.call(context)
    else
      context.response.status = Gemini::Status::NotFound
    end
  end

  alias HandlerProc = Gemini::Server::Context ->
end

require "./handlers/*"

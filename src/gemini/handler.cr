class Gemini::Server;end
  property next : Handler | HandlerProc | Nil

  abstract def call(context : Crem::Gemini::Server::Context)

  def call_next(context : Crem::Gemini::Server::Context)
    if next_handler = @next
      next_handler.call(context)
    else
      context.response.status = Gemini::Status::NotFound
    end
  end

  alias HandlerProc = Gemini::Server::Context ->
end

class Gemini::Server::InternalRedirectHandler
  include Gemini::Server::Handler

  def initialize(@redirects : Hash(String, String)); end

  def call(context)
    if new_path = @redirects[context.request.uri.path]?
      context.request.uri.path = new_path
    end

    call_next(context)
  end
end

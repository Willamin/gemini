class Gemini::Server::StaticHandler
  include Gemini::Server::Handler

  def initialize(@root : String); end

  def call(context)
    path = Path.new(@root, context.request.uri.path)

    context.response.content_type = MIME.from_extension?(path.extension)

    if File.exists?(path)
      context.response.status = Gemini::Status::Success
      context.response.print File.read(path)
    else
      context.response.status = Gemini::Status::NotFound
      call_next(context)
    end
  end
end

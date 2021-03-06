class Gemini::Server::StaticHandler
  include Gemini::Server::Handler

  def initialize(@root : String, @fallthrough = false); end

  def call(context)
    path = Path.new(@root, context.request.uri.path)

    context.response.content_type = MIME.from_extension?(path.extension)

    if File.exists?(path) && File.file?(path)
      context.response.status = Gemini::Status::Success
      context.response.print File.read(path)
    else
      if @fallthrough
        call_next(context)
      else
        context.response.status = Gemini::Status::NotFound
      end
    end
  end
end

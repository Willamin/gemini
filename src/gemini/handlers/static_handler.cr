class Crem::Gemini::Server::StaticHandler
  include Crem::Gemini::Server::Handler

  def initialize(@root : String); end

  def call(context)
    path = Path.new(@root, context.request.uri.path)

    puts("looking for #{path}")
    context.response.content_type = MIME.from_extension?(path.extension)

    if File.exists?(path)
      context.response.status = Crem::Gemini::Status::Success
      context.response.print File.read(path)
    else
      context.response.status = Crem::Gemini::Status::NotFound
      call_next(context)
    end
  end
end

class Gemini::Server::LogHandler
  include Gemini::Server::Handler

  def initialize(@io : IO); end

  def call(context)
    path_before = context.request.uri.path
    call_next(context)
    path_after = context.request.uri.path

    @io.print(Time.utc)
    @io.print(": ")
    @io.print(path_before)
    if path_before != path_after
      @io.print(" -> ")
      @io.print(path_after)
    end
    @io.print(" ")
    @io.print(context.response.status.to_i32)
    @io.puts()
  end
end

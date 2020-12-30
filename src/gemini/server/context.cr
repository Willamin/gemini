class Gemini::Server::Context
  getter request : Request
  getter response : Response = Response.new

  def initialize(@request); end
end

class Gemini::Server::Context::Request
  property uri

  def initialize(raw : String)
    @uri = URI.parse(raw)
  end
end

class Gemini::Server::Context::Response
  property status : Gemini::Status = Gemini::Status::TemporaryFailure
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


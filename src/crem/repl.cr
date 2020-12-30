class Crem::REPL
  @history = [] of String

  def start
    Signal::INT.trap do
      puts("~~ see you! ~~")
      exit(0)
    end

    Crem::Gemini::Client.open do |client|
      loop do
        print("uri to fetch: ")
        if line = STDIN.gets
          @history << line
          response = client.fetch(line.strip)
          case response
          when Gemini::Response::Success then puts(response.io.gets_to_end)
          end
          puts("\n-------\n")
        end
      end
    end
  end
end

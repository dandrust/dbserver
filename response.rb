class Response
  attr_reader :headers, :body, :status, :version

  class Status < Data.define(:code, :text)
    OK = new(200, "OK")
    BAD_REQUEST = new(400, "Bad Request")
    NOT_FOUND = new(404, "Not Found")
    SERVER_ERROR = new(500, "Internal Server Error")
    
    def to_s
      "#{code} #{text}"
    end
  end
  
  def initialize
    @version = "1.1"
    @body = ""
    @headers = {
      "Content-Type" => "text/html"
    }
  end

  def not_found
    @status = Status::NOT_FOUND
  end

  def ok(body = nil)
    @status = Status::OK
    @body = body if body
  end

  def bad_request(body = nil)
    @status = Status::BAD_REQUEST
    @body = body if body
  end

  def server_error
    @status = Status::SERVER_ERROR
  end

  def to_s
    out = "HTTP/#{version} #{status}\r\n"
    headers.each do |k, v|
      out += "#{k}: #{v}\r\n"
    end
    out += "Content-Length: #{body&.bytesize}\r\n\r\n"
    out += body
    out
  end
end

require 'socket'
require 'singleton'
require 'stringio'

# A small persistence library that, at the moment, only
# implements an in-memory persistence strategy for getting
# and setting key-value pairs
module Persistence
  module_function

  class PersistenceError < StandardError; end

  class InMemory
    include Singleton

    class << self
      def get(*)
        instance.get(*)
      end

      def set!(*)
        instance.set!(*)
      end
    end

    def initialize
      @storage = {}
    end

    def get(key)
      storage[key]
    end

    def set!(key, value)
      @storage[key] = value
    end

    private

    attr_reader :storage
  end

  def in_memory
    InMemory
  end

  def file_based
    raise "Not Implemented"
  end
end

# A simple routing layer that allows stores GET and PUT
# routes and can match incoming requests to existing routes
module Routing
  class Route < Data.define(:verb, :path, :handler)
    def ===(other)
      case other
      when Request, Route
        other.verb == verb && other.path == path
      else
        false
      end
    end
  end

  class Router
    attr_reader :routes, :application

    def initialize(application)
      @application = application
      @routes = []
    end

    def get(path, handler)
      @routes << Route.new("GET", path, handler)
    end

    def put(path, handler)
      @routes << Route.new("PUT", path, handler)
    end

    def route(request)
      routes.find do |route|
        route === request
      end
    end
  end
end

# A thin application layer gluing routing and persistence.
# Complies with the expected `handle(request, response)` 
# interface expected by the Server class
class Application
  attr_reader :router, :persistence
  
  def initialize
    @router = Routing::Router.new(self)
    router.get("/get", :get)
    router.put("/set", :set)

    @persistence = Persistence::InMemory
  end

  def handle(request, response)
    route = router.route(request)
    return response.not_found unless route
    
    send(route.handler, request.params, response)
    response
  rescue StandardError => e
    puts e.backtrace
    response.server_error
  end

  private

  def get(params, response)
    return response.bad_request unless params["key"]

    value = persistence.get(params["key"])
    value ||= "NULL"
    response.ok(value)
  end

  def set(params, response)
    key, value = params.first
    return response.bad_request unless key
    
    persistence.set!(key, value)
    response.ok(value)
  rescue Persistence::PersistenceError
    response.server_error
  end
end

# Parses an incoming HTTP request and provides an
# interface to interrogate relevant parts like
# request type, request path, and query params
class Request
  attr_reader :raw_request, :verb, :path, :version, :headers, :body, :params

  def initialize
    @raw_request = StringIO.new
  end

  def collect(str)
    @raw_request << str
    @headers = {}
    @params = {}
  end
      
  def parse
    raw_request.rewind
    request_line = raw_request.gets
    @verb, @path, @version = request_line.split

    @path, query_params = @path.split("?")

    if query_params
      query_params.split("&").each do |param|
        k, v = param.split("=")
        @params[k] = v
      end
    end

    while line = raw_request.gets
      k, v = line.chomp.split(": ")
      @headers[k] = v
    end
  end

  def to_s
    out = "#{verb} #{path} #{version}\n"
    headers.each do |k, v|
      out += "#{k}: #{v}\n"
    end
    out
  end
end

# Barebones HTTP response implementing codes 200, 400,
# 404, and 500
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

# Server handles accepting incoming connections and
# sending outgoing responses.  It takes an application
# instance that responsds to `handle(request, response)`
class Server
  attr_reader :server, :application

  class << self
    def run(application)
      new(application).run
    end
  end

  def initialize(application)
    @server = TCPServer.new 4000
    @application = application
  end

  def run
    loop do
      client = server.accept
      request = Request.new
      response = Response.new
      
      while (line = client.gets) != "\r\n"
        request.collect(line)
      end
      
      request.parse
      application.handle(request, response)

      client.puts response.to_s
      client.close
    end
  end
end

Server.run(Application.new)

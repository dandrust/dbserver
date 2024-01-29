require 'socket'
require_relative "request"
require_relative "response"

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

module Routing
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
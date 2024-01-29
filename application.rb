require_relative "persistence"
require_relative "routing"

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
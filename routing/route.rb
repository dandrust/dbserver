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
end
  
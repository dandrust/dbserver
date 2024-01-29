require 'stringio'

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
  
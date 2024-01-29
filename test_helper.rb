require 'socket'

def send_request(verb, path, **params)
    s = TCPSocket.new 'localhost', 4000
    
    query_params = 
      params
      .map { |k, v| "#{k}=#{v}" }
      .join("&")
      .tap do |str|
        str.prepend("?") unless str.empty?
      end
  
    s.puts "#{verb} /#{path}#{query_params} HTTP/1.1 \r\nHost: localhost:4000\r\n\r\n"
    s.read
  end
  
  def get(path, **params)
    send_request("GET", path, **params)
  end
  
  def put(path, **params)
    send_request("PUT", path, **params)
  end
  
  def expect_ok(response)
    expect response.match?("200 OK")
  end
  
  def expect_not_found(response)
    expect response.match?("404 Not Found")
  end
  
  def expect_bad_request(response)
    expect response.match?("400 Bad Request")
  end
  
  def expect(predicate)
    puts predicate ? "✅" : "❌"
  end
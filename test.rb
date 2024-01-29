require_relative 'test_helper'

print "it returns 404 Not Found when hitting an undefined endpoint..."
expect_not_found get(:unknown)

print "it returns 400 bad request when key isn't provided to /get endpoint..."
expect_bad_request get(:get)

puts "it returns 'NULL' when fetching an unset key..."
response = get(:get, key: :foo)
print "\t 200..."
expect_ok response
print "\t 'NULL'..."
expect response.chomp.end_with?("NULL")

puts "it sets a key when hitting /put endpoint"
key = "bar"
value = "baz"
\
put_response = put(:set, key => value)
print "\t 200..."
expect_ok put_response
print "\t get..."
get_response = get(:get, key: key)
expect get_response.chomp.end_with?(value)



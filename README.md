A small key-value database server implementation.

To run:
```bash
ruby ./main.rb
```

Setting keys:
```curl
curl -i --request PUT --url "http://localhost:4000/set?foo=bar"
```

Getting values:
```curl
curl -i --url "http://localhost:4000/get?key=foo"
```
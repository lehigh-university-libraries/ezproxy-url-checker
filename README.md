# ezproxy-url-checker

Check whether a URL exists in your EZproxy config.

## Quickstart

Generate the files the service needs to determine if a URL should be proxied
```
./scripts/generate_files.sh /path/to/ezproxy/config.txt/folder
```

Build/run the docker container
```
docker build -t ezproxy-proxy-url:latest .
docker run \
  -d \
  --name ezproxy-proxy-url \
  -v $(pwd)/config:/app/config \
  --rm \
  --env LISTEN="127.0.0.1:8080"
  -p 8080:8080 \
  ezproxy-proxy-url:latest
```

See if google scholar is in your EZproxy config

```
curl http://localhost:8080/proxyUrl?url=scholar.google.com
```

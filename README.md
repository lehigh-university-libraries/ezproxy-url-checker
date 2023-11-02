# ezproxy-url-checker

Check whether a URL exists in your EZproxy config.

## Quickstart

```
./scripts/generate_files.sh /path/to/ezproxy/config.txt/folder
docker build -t ezproxy-proxy-url:latest .
docker run \
  -d \
  --name ezproxy-proxy-url \
  -v $(pwd)/config:/app/config \
  --rm \
  -p 8080:8080 \
  ezproxy-proxy-url:latest

# see if google scholar is in your EZproxy config
curl http://localhost:8080/proxyUrl?url=scholar.google.com
```

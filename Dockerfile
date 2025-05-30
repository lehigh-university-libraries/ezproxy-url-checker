FROM golang:1.24-bullseye@sha256:abe2e2bb9bc0342dd1ba2f719af5c6b3859ca9ad93a7d9bcdd21310bda0327e1

WORKDIR /app

COPY . ./

RUN go mod download \
  && go build \
  && go clean -cache -modcache

ENTRYPOINT [ "/app/ezproxy-url-checker"]

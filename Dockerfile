FROM golang:1.21-bullseye

WORKDIR /app

COPY . ./

RUN go mod download \
  && go build \
  && go clean -cache -modcache

ENTRYPOINT [ "/app/ezproxy-url-checker"]

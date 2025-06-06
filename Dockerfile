FROM golang:1.24-bullseye@sha256:12152217ef79f60fd71a64375d818b7be68c69c7611ca471c2e2c28324cbf4cd

WORKDIR /app

COPY . ./

RUN go mod download \
  && go build \
  && go clean -cache -modcache

ENTRYPOINT [ "/app/ezproxy-url-checker"]

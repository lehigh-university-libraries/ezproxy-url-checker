FROM golang:1.21-bullseye@sha256:40a67e6626bead90d5c7957bd0354cfeb8400e61acc3adc256e03252630014a6

WORKDIR /app

COPY . ./

RUN go mod download \
  && go build \
  && go clean -cache -modcache

ENTRYPOINT [ "/app/ezproxy-url-checker"]

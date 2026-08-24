FROM golang:1.24-bullseye@sha256:2cdc80dc25edcb96ada1654f73092f2928045d037581fa4aa7c40d18af7dd85a

WORKDIR /app

COPY . ./

RUN go mod download \
  && go build \
  && go clean -cache -modcache

ENTRYPOINT [ "/app/ezproxy-url-checker"]

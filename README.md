# ezproxy-url-checker

Check whether a URL exists in your EZproxy config.

## Quickstart

Download the binary from [the latest release](https://github.com/lehigh-university-libraries/ezproxy-url-checker/releases/latest). An automated way to do that might be:

```
./scripts/download-binary.sh
```

Generate the files the service needs from your EZProxy config and start the service

```
./scripts/generate_files.sh /path/to/ezproxy/config.txt/folder
./ezproxy-url-checker
```

See if google scholar is in your EZproxy config

```
curl "http://localhost:8888/proxyUrl?url=https://scholar.google.com"
```

## TODO

- [ ] Integration tests
- [ ] CI/CD instructions
- [ ] Better API Documentation

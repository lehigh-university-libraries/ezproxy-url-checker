# ezproxy-url-checker

Check whether a URL exists in your EZproxy config.

## Quickstart

Download the binary from [the latest release](https://github.com/lehigh-university-libraries/ezproxy-url-checker/releases/latest). An automated way to do that might be:

```
# Full list of available architectures can be seen at https://github.com/lehigh-university-libraries/ezproxy-url-checker/releases/latest
ARCH="Linux_x86_64"
TAG=$(gh release list --exclude-pre-releases --exclude-drafts --limit 1 --repo lehigh-university-libraries/ezproxy-url-checker | awk '{print $3}')
gh release download $TAG --repo lehigh-university-libraries/ezproxy-url-checker --pattern 'ezproxy-url-checker_$ARCH.tar.gz"
tar -zxvf $ARCH
rm $ARCH
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

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


## Deployment

**Coming soon**: instructions on how to get the config files needed for the service from EZProxy onto your system.

### init

To deploy this service to a server, first, you'll need to deploy the binary to your system.

```
$ cd /opt
$ git clone https://github.com/lehigh-university-libraries/ezproxy-url-checker.git
$ cd ezproxy-url-checker
$ ./scripts/download-binary.sh
```

Then you'll need to start the service with your preferred init system.

#### systemd

If you use systemd, you could create a unit file for this service. 

```
$ cat << EOF >/etc/systemd/system/ezproxy-url-checker.service
[Install]
WantedBy=multi-user.target

[Unit]
Description=ezproxy-url-checker
After=gcr-online.target

[Service]
WorkingDirectory=/opt/ezproxy-url-checker
Restart=on-failure
RestartSec=30s
ExecStart=/opt/ezproxy-url-checker/ezproxy-url-checker
EOF

$ systemctl enable ezproxy-url-checker.service
$ systemctl start ezproxy-url-checker.service
```

### docker

## TODO

- [ ] Integration tests
- [ ] CI/CD instructions
- [ ] Better API Documentation
- [ ] Add docker deployment instructions

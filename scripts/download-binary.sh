#!/usr/bin/env bash

set -eou pipefail

# Originally from https://github.com/dasginganinja/drush-launcher/blob/c9d90d4ff02dccccf133f1f7419a0d6983ed367d/download_and_build.sh
# Modified to match gorelease default binary names
# Also verified checksums

# Define the GitHub repository owner, repository name, and binary name
repo_owner="lehigh-university-libraries"
repo_name="ezproxy-url-checker"
binary_name="ezproxy-url-checker"

# Function to download the release asset from GitHub
download_release_asset() {
    local ASSET="$1"
    download_url="https://github.com/${repo_owner}/${repo_name}/releases/download/${latest_release}/$ASSET"
    echo "Downloading ${latest_release} release..."
    curl -s -L -o "${ASSET}" "$download_url"
    curl -s -L -o checksums.txt "https://github.com/${repo_owner}/${repo_name}/releases/download/${latest_release}/checksums.txt"
    CHECKSUM_SOURCE=$(grep "$ASSET" checksums.txt)
    CHECKSUM_DL=$(sha256sum $ASSET)
    if [ "$CHECKSUM_SOURCE" != "$CHECKSUM_DL" ]; then
      echo "Checksums do not match."
      rm "$ASSET" checksums.txt
      exit 1
    fi

    if [[ "$GOOS" == "Windows" ]]; then
      unzip $ASSET
    else
      tar -zxf "$ASSET"
    fi
    rm $ASSET checksums.txt
}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    GOOS="Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    GOOS="Darwin"
elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    GOOS="Windows"
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

# Detect the architecture
if [[ "$GOOS" == "windows" ]]; then
    GOARCH="$PROCESSOR_ARCHITECTURE"
else
    GOARCH=$(uname -m)
fi

# Fetch the latest release version using GitHub API
latest_release=$(curl -s "https://api.github.com/repos/${repo_owner}/${repo_name}/releases/latest" | jq -r '.tag_name')
latest_version=$(echo "${latest_release}" | cut -c 2-)

# Check if the latest release version is available
if [ -z "$latest_release" ]; then
    echo "Failed to fetch the latest release version."
    exit 1
fi

# Determine the binary extension based on the operating system
if [[ "$GOOS" == "Windows" ]]; then
    binary_extension=".zip"
else
    binary_extension=".tar.gz"
fi

# Check if the required binary for the user's architecture exists in the latest release
binary_filename="${binary_name}_${GOOS}_${GOARCH}${binary_extension}"
echo "Binary filename: " $binary_filename
release_assets=$(curl -s "https://api.github.com/repos/${repo_owner}/${repo_name}/releases/tags/${latest_release}" | jq -r '.assets[].name')
if [[ "$release_assets" == *"$binary_filename"* ]]; then
    echo "Binary for ${GOOS}-${GOARCH} architecture found in the latest release."
    download_release_asset "${binary_name}_${GOOS}_${GOARCH}${binary_extension}"
else
    echo "Binary for ${GOOS}-${GOARCH} architecture not found in the latest release. Attempting to build locally..."
    go build -o "${binary_name}"
fi

# Make the binary executable
chmod +x "${binary_name}"

echo "The ${binary_name} binary is ready."

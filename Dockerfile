# Stage 1: Build environment (Debian/Ubuntu as an example)
FROM ubuntu:latest AS builder

# Update package lists and install required packages
RUN apt-get update && apt-get install -y software-properties-common

# Update package lists and install pack
RUN add-apt-repository ppa:cncf-buildpacks/pack-cli
RUN apt-get update
RUN apt-get install pack-cli

FROM quay.io/podman/stable:latest

COPY --from=builder /usr/bin/pack /usr/bin/pack

# Set unqualified search registry (optional)
RUN echo 'unqualified-search-registries = ["docker.io"]' > /etc/containers/registries.conf

# Install necessary packages for rootless Podman
RUN dnf install -y fuse-overlayfs slirp4netns 

RUN dnf install -y https://kojipkgs.fedoraproject.org//packages/crun/1.8.7/1.fc38/x86_64/crun-1.8.7-1.fc38.x86_64.rpm



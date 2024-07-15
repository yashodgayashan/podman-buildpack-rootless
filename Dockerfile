# Stage 1: Build environment (Debian/Ubuntu as an example)
FROM ubuntu:latest AS builder

# Update package lists and install required packages
RUN apt-get update && apt-get install -y software-properties-common

# Update package lists and install pack
RUN add-apt-repository ppa:cncf-buildpacks/pack-cli
RUN apt-get update
RUN apt-get install pack-cli

FROM mgoltzsche/podman:latest

COPY --from=builder /usr/bin/pack /usr/bin/pack

# Set unqualified search registry (optional)
RUN echo 'unqualified-search-registries = ["docker.io"]' > /etc/containers/registries.conf

RUN apk update && apk add --no-cache shadow

# Create a non-root user and home directory
# RUN useradd -m tektonuser

# Create the working directory and set ownership
# RUN mkdir -p /home/podman && chown -R tektonuser:tektonuser /home/tekton

# # Install necessary packages for rootless Podman
# RUN dnf install -y fuse-overlayfs slirp4netns 

# Switch to the target user with reduced privileges
USER 1000

# Working directory for Tekton
WORKDIR /home/podman
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

# Create a non-root user and home directory
RUN useradd -m tektonuser

# Create the working directory and set ownership
RUN mkdir -p /home/tekton && chown -R tektonuser:tektonuser /home/tekton

# Create the necessary runtime directory and set ownership
RUN mkdir -p /run/user/1000 && chown -R tektonuser:tektonuser /run/user/1000

RUN mkdir -p /home/tekton/.run/user/1000 && chown -R tektonuser:tektonuser /home/tekton/.run/user/1000

# Ensure correct permissions for Podman storage directories
RUN mkdir -p /home/tekton/.local/share/containers && chown -R tektonuser:tektonuser /home/tekton/.local/share/containers

# Install necessary packages for rootless Podman
RUN dnf install -y fuse-overlayfs slirp4netns

# Switch to the target user with reduced privileges
USER tektonuser

# Working directory for Tekton
WORKDIR /home/tekton


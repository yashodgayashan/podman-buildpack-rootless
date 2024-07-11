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

# Install necessary packages for rootless Podman
RUN dnf install -y fuse-overlayfs slirp4netns

# Add custom storage configuration
RUN mkdir -p /home/tekton/.config/containers && \
    echo '[storage]' > /home/tekton/.config/containers/storage.conf && \
    echo '  driver = "overlay"' >> /home/tekton/.config/containers/storage.conf && \
    echo '  graphroot = "/tmp/storage"' >> /home/tekton/.config/containers/storage.conf && \
    echo '  runroot = "/tmp/run"' >> /home/tekton/.config/containers/storage.conf && \
    echo '  [storage.options]' >> /home/tekton/.config/containers/storage.conf && \
    echo '    mount_program = "/usr/bin/fuse-overlayfs"' >> /home/tekton/.config/containers/storage.conf && \
    chown -R tektonuser:tektonuser /home/tekton/.config

# Ensure storage paths are created and writable
RUN mkdir -p /tmp/storage /tmp/run && \
    chown -R tektonuser:tektonuser /tmp/storage /tmp/run

# Switch to the target user with reduced privileges
USER tektonuser

# Working directory for Tekton
WORKDIR /home/tekton

# Set environment variables
ENV STORAGE_DRIVER=overlay
ENV STORAGE_CONF=/home/tekton/.config/containers/storage.conf

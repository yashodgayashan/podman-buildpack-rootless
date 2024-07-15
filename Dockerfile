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
RUN mkdir -p /home/podman && chown -R podman:podman /home/podman

RUN sed -i 's|graphroot = "/var/lib/containers/storage"|graphroot = "/home/podman/.local/share/containers/storage"|' /etc/containers/storage.conf

RUN mkdir -p /home/podman/.local/share/containers/storage/overlay
RUN mkdir -p /home/podman/.local/share/containers/storage/libpod
RUN chmod 666 /home/podman/.local/share/containers/storage/libpod
RUN chmod 777 /home/podman/.local/share/containers/storage/overlay
RUN chown -R podman:podman /home/podman

RUN cat /etc/containers/storage.conf

# Install necessary packages for rootless Podman
RUN dnf install -y fuse-overlayfs slirp4netns

RUN mkdir -p /etc/containers && printf '[containers]\napparmor_profile = "unconfined"\n' > /etc/containers/containers.conf
RUN mkdir -p /home/podman/.config/containers && printf '[containers]\napparmor_profile = "unconfined"\n' > /home/podman/.config/containers/containers.conf
RUN mkdir -p /usr/share/containers && printf '[containers]\napparmor_profile = "unconfined"\n' > /usr/share/containers/containers.conf

# Switch to the target user with reduced privileges
USER 1000

# Working directory for Tekton
WORKDIR /home/podman

# Use an official minimal image as a base
FROM alpine:latest

# Install necessary packages
RUN apk update && apk add --no-cache \
    podman \
    fuse-overlayfs \
    shadow \
    && rm -rf /var/cache/apk/*

# Create a non-root user and group with specific IDs
RUN groupadd -g 1000 podmanuser && \
    useradd -u 1000 -g podmanuser -m -s /bin/sh podmanuser

# Configure Podman for rootless mode
RUN mkdir -p /etc/containers && \
    echo "[registries.search]" > /etc/containers/registries.conf && \
    echo "registries = ['docker.io']" >> /etc/containers/registries.conf

# Set the entrypoint to podman and set environment variables
USER 1000:1000

# Create necessary directories and set up environment
RUN mkdir -p /home/podmanuser/.config/containers && \
    echo "[containers]" > /home/podmanuser/.config/containers/containers.conf && \
    echo "netns='bridge'" >> /home/podmanuser/.config/containers/containers.conf

# Expose default ports if needed (adjust as necessary)
EXPOSE 8080

# Set the entrypoint to podman
ENTRYPOINT ["podman"]

# Default command to run in rootless mode
CMD ["--help"]

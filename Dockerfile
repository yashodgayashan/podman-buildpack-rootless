# Use an appropriate base image
FROM fedora:latest

# Install Podman
RUN dnf -y update && \
    dnf -y install podman

# Create a user for running Podman rootless
RUN useradd -ms /bin/bash podmanuser

# Switch to the new user
USER podmanuser

# Set up environment for rootless Podman
ENV XDG_RUNTIME_DIR=/tmp/run
RUN mkdir -p /tmp/run && \
    podman system migrate

# Entry point
ENTRYPOINT ["/usr/bin/podman"]
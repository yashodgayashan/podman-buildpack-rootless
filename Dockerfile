FROM fedora:latest

# Install Podman and necessary dependencies
RUN dnf -y update && \
    dnf -y install podman fuse-overlayfs slirp4netns iptables shadow-utils && \
    dnf clean all

# Create a user for running Podman rootless
RUN useradd -ms /bin/bash podmanuser

# Switch to the new user
USER podmanuser

# Set up environment for rootless Podman
ENV XDG_RUNTIME_DIR=/tmp/run
RUN mkdir -p /tmp/run && chmod 700 /tmp/run && \
    mkdir -p /home/podmanuser/.local/share/containers/storage && \
    podman --version && \
    podman info

# Entry point
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["podman info"]

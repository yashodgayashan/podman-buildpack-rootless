# Use an official Fedora base image
FROM fedora:latest

# Install Podman and other necessary tools
RUN dnf -y update && \
    dnf -y install podman fuse-overlayfs slirp4netns shadow-utils

# Create a non-root user and group
RUN groupadd -r mygroup && useradd -r -g mygroup -m -d /home/myuser myuser

# Set up environment for rootless Podman
USER myuser
ENV HOME /home/myuser
RUN mkdir -p $HOME/.local/share/containers/storage && \
    mkdir -p $HOME/.config/containers && \
    echo -e "[engine]\ncgroup_manager = \"cgroupfs\"\nevents_logger = \"file\"\n" > $HOME/.config/containers/containers.conf

# Set up directories and environment variables
ENV XDG_RUNTIME_DIR=/run/user/$(id -u) \
    STORAGE_DRIVER=overlay

# Create the necessary directories for rootless Podman
RUN mkdir -p $XDG_RUNTIME_DIR && chmod 700 $XDG_RUNTIME_DIR

# Set the working directory
WORKDIR $HOME

# Ensure that slirp4netns and fuse-overlayfs are set correctly
RUN echo -e "[[runtimes]]\nname = \"slirp4netns\"\npath = \"/usr/bin/slirp4netns\"\n" >> $HOME/.config/containers/containers.conf && \
    echo -e "[storage.options]\nmount_program = \"/usr/bin/fuse-overlayfs\"\n" >> $HOME/.config/containers/storage.conf

# Entry point to start Podman in rootless mode
ENTRYPOINT ["podman"]
CMD ["--help"]

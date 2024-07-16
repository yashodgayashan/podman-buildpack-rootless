# Use an official Fedora base image
FROM fedora:latest

# Install Podman and other necessary tools
RUN dnf -y update && \
    dnf -y install podman fuse-overlayfs slirp4netns shadow-utils

# Create a non-root user and group
RUN groupadd -r mygroup && useradd -r -g mygroup -m -d /home/myuser myuser

# Switch to the non-root user
USER myuser
ENV HOME /home/myuser

# Set up environment for rootless Podman
RUN mkdir -p $HOME/.local/share/containers/storage && \
    mkdir -p $HOME/.config/containers && \
    echo -e "[engine]\ncgroup_manager = \"cgroupfs\"\nevents_logger = \"file\"\n" > $HOME/.config/containers/containers.conf

RUN podman info

# Set up directories and environment variables
RUN mkdir -p /run/user/1000 && chmod 700 /run/user/1000
ENV XDG_RUNTIME_DIR=/run/user/1000 \
    STORAGE_DRIVER=overlay

# Ensure that slirp4netns and fuse-overlayfs are set correctly
RUN echo -e "[[runtimes]]\nname = \"slirp4netns\"\npath = \"/usr/bin/slirp4netns\"\n" >> $HOME/.config/containers/containers.conf && \
    echo -e "[storage.options]\nmount_program = \"/usr/bin/fuse-overlayfs\"\n" >> $HOME/.config/containers/storage.conf

# Set the working directory
WORKDIR $HOME

# Entry point to start Podman in rootless mode
ENTRYPOINT ["podman"]
CMD ["--help"]

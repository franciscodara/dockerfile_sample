FROM ubuntu:latest

LABEL maintainer="Francisco Dara"
LABEL maintainer_email="dara@codara.tech"
LABEL description="Dockerfile ubuntu with openssh"
LABEL license="MIT"
LABEL license_url=""
LABEL version="1.0"
LABEL vendor="Codara"
LABEL website="http://www.codara.tech"

# Up to date operational system
RUN apt-get update
RUN apt-get install -y openssh-server vim curl

# Set up the SSH server
RUN mkdir /var/run/sshd
RUN echo 'root:root' |chpasswd
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN echo 'Banner /etc/banner' >> /etc/ssh/sshd_config
RUN mkdir /root/.ssh

# Clear temporary files
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create user and set password
RUN useradd -ms /bin/bash dara
RUN adduser dara sudo
RUN echo 'dara:d@7865R@' |chpasswd
USER dara

# Install node with created user
RUN /bin/bash -l -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash"
RUN /bin/bash -l -c ". ~/.nvm/nvm.sh && nvm install node"

# Come back to root
USER root

COPY etc/banner /etc/

# Set up port forwarding
EXPOSE 22
EXPOSE 3090

# Volume mount
RUN mkdir /workspace
RUN chmod 777 /workspace
VOLUME /workspace

# Execute the command
CMD    ["/usr/sbin/sshd", "-D"]

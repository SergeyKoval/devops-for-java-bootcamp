FROM jenkins/inbound-agent:latest

# Install Docker
USER root
RUN apt-get update && \
    apt-get install -y docker.io && \
    rm -rf /var/lib/apt/lists/*

RUN usermod -aG docker jenkins

# Set up Docker daemon for Docker-in-Docker (DinD)
RUN dockerd &

# Switch back to jenkins user
USER jenkins

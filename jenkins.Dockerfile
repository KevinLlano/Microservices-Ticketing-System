FROM jenkins/jenkins:lts

USER root

# Install Docker, AWS CLI, and Maven
RUN apt-get update && \
    apt-get install -y \
    docker.io \
    awscli \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Add jenkins user to docker group
RUN usermod -aG docker jenkins

# Fix volume permissions for Windows
RUN chown -R jenkins:jenkins /var/jenkins_home && \
    chmod -R 755 /var/jenkins_home

USER jenkins

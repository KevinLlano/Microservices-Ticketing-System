FROM jenkins/jenkins:lts

USER root

# Install Docker CLI + Maven + curl (simplified)
RUN apt-get update && apt-get install -y docker.io maven curl && rm -rf /var/lib/apt/lists/*

# Add jenkins user to docker group
RUN usermod -aG docker jenkins

# (Optional) Pre-create home (ownership will also be fixed at runtime entrypoint)
RUN mkdir -p /var/jenkins_home && chown -R jenkins:jenkins /var/jenkins_home

# Minimal plugins only (docker pipeline + workflow + git)
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt || true

# Runtime entrypoint will fix volume permissions before starting Jenkins
ENTRYPOINT ["/bin/sh","-c","chown -R 1000:1000 /var/jenkins_home && exec /usr/bin/tini -- /usr/local/bin/jenkins.sh"]

USER jenkins

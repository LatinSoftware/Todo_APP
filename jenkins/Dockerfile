FROM jenkins/jenkins:lts

USER root

# Install Docker CLI
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# SOLUCIÓN AL ERROR DE PERMISOS:
# Creamos el grupo docker con el GID estándar (999) y añadimos a jenkins.
# Nota: Si en tu host 'ls -ln /var/run/docker.sock' muestra un ID distinto a 999, cámbialo aquí.
RUN groupadd -g 999 docker && usermod -aG docker jenkins

USER jenkins
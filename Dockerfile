# Usamos la última versión estable de Ubuntu
FROM ubuntu:22.04

# Evitar que apt-get haga preguntas interactivas durante el build
ENV DEBIAN_FRONTEND=noninteractive \
    TEST_MODE=1 \
    AUTO_SELECT="nvim kitty rust zsh colima opencode fish" \
    TERM=xterm-256color \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# 1. Instalar dependencias básicas para que el script pueda correr
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    zsh \
    git \
    gnupg \
    software-properties-common \
    ncurses-bin \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2. Crear el usuario 'archer' (igual que en tu máquina)
# Le damos permisos de sudo sin contraseña para las pruebas
RUN useradd -m -s /bin/bash archer && \
    echo "archer ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER archer
WORKDIR /home/archer/quiver

# 3. Copiar los archivos del proyecto
# Usamos --chown para que el usuario archer sea el dueño
COPY --chown=archer:archer . .

# Asegurar permisos de ejecución
RUN chmod +x install.sh

# 4. Comando por defecto
# Al arrancar, ejecutará el script con Bash explícitamente.
# El script tiene shebang #!/usr/bin/env bash
CMD ["/bin/bash", "./install.sh"]

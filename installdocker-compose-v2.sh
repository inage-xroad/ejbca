#!/bin/bash

# Script: install-docker-compose-v2.sh
# Objetivo: Instalar o Docker Compose V2 no Ubuntu (modo plugin oficial)
# Autores: Inspirado por boas práticas de engenharia de software

set -euo pipefail

# Versão estável desejada
COMPOSE_VERSION="v2.24.5"

# Caminho padrão para plugin do Docker Compose V2
PLUGIN_DIR="/usr/local/libexec/docker/cli-plugins"
PLUGIN_PATH="${PLUGIN_DIR}/docker-compose"

echo "Verificando permissões..."
if [[ $EUID -ne 0 ]]; then
  echo "Este script precisa ser executado como root." >&2
  exit 1
fi

echo "Criando diretório do plugin (se necessário)..."
mkdir -p "$PLUGIN_DIR"

echo "Baixando Docker Compose V2: ${COMPOSE_VERSION}"
curl -fsSL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64" \
  -o "$PLUGIN_PATH"

echo "Tornando binário executável..."
chmod +x "$PLUGIN_PATH"

echo "Verificando instalação:"
docker compose version

#!/bin/bash

set -euo pipefail

# Caminho base do projeto (pasta onde o docker-compose.yml está)
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${BASE_DIR}/docker-compose.yml"

# Diretório de backup (personalize conforme necessário)
BACKUP_DIR="/home/backup/ejbca"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_NAME="ejbca-backup-${TIMESTAMP}"
DB_VOLUME="db_data"
EJBCA_VOLUME="ejbca_data"

# Garante que o diretório de backup existe
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

usage() {
  echo "Uso:"
  echo "  $0 backup                - Cria um backup completo"
  echo "  $0 restore <diretorio>   - Restaura um backup existente"
  exit 1
}

backup() {
  echo "[INFO] Parando os serviços do EJBCA..."
  docker compose -f "$COMPOSE_FILE" down

  echo "[INFO] Criando backup do volume do banco de dados (${DB_VOLUME})..."
  docker run --rm \
    -v ${DB_VOLUME}:/volume \
    -v "$BACKUP_DIR":/backup \
    alpine \
    tar czf /backup/${BACKUP_NAME}-db.tar.gz -C /volume .

  echo "[INFO] Criando backup do volume da aplicação (${EJBCA_VOLUME})..."
  docker run --rm \
    -v ${EJBCA_VOLUME}:/volume \
    -v "$BACKUP_DIR":/backup \
    alpine \
    tar czf /backup/${BACKUP_NAME}-ejbca.tar.gz -C /volume .

  echo "[OK] Backup criado em: $BACKUP_DIR"
}

restore() {
  BACKUP_FOLDER="$1"
  if [[ -z "$BACKUP_FOLDER" || ! -d "$BACKUP_FOLDER" ]]; then
    echo "[ERRO] Diretório de backup inválido: '$BACKUP_FOLDER'"
    usage
  fi

  echo "[INFO] Parando e removendo serviços e volumes..."
  docker compose -f "$COMPOSE_FILE" down -v || true
  docker volume rm -f ${DB_VOLUME} ${EJBCA_VOLUME} || true

  echo "[INFO] Restaurando volume do banco de dados (${DB_VOLUME})..."
  docker volume create ${DB_VOLUME}
  docker run --rm \
    -v ${DB_VOLUME}:/volume \
    -v "$BACKUP_FOLDER":/backup \
    alpine \
    tar xzf /backup/*-db.tar.gz -C /volume

  echo "[INFO] Restaurando volume da aplicação (${EJBCA_VOLUME})..."
  docker volume create ${EJBCA_VOLUME}
  docker run --rm \
    -v ${EJBCA_VOLUME}:/volume \
    -v "$BACKUP_FOLDER":/backup \
    alpine \
    tar xzf /backup/*-ejbca.tar.gz -C /volume

  echo "[INFO] Iniciando os serviços..."
  docker compose -f "$COMPOSE_FILE" up -d

  echo "[OK] Restauração concluída com sucesso."
}

# Main
case "${1:-}" in
  backup)
    backup
    ;;
  restore)
    restore "${2:-}"
    ;;
  *)
    usage
    ;;
esac

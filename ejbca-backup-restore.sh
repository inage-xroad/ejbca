#!/bin/bash

# Caminho fixo para o arquivo docker-compose.yml
COMPOSE_FILE="/srv/ejbca/containers/docker-compose.yml"

# Diretório onde os backups serão armazenados
BACKUP_DIR="/srv/ejbca/backups/ejbca"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_NAME="ejbca-backup-$TIMESTAMP"
DB_VOLUME="db_data"
EJBCA_VOLUME="ejbca_data"

# Garante que o diretório de backup existe e tem permissão segura
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

# Exibe a forma correta de uso
usage() {
  echo "Uso:"
  echo "  $0 backup                - Cria um backup completo"
  echo "  $0 restore <diretorio>   - Restaura um backup existente"
  exit 1
}

# Função de backup
backup() {
  echo "[INFO] Parando os serviços do EJBCA..."
  docker compose -f "$COMPOSE_FILE" down

  echo "[INFO] Criando backup do volume do banco de dados ($DB_VOLUME)..."
  docker run --rm -v ${DB_VOLUME}:/volume -v "$BACKUP_DIR":/backup alpine \
    tar czf /backup/${BACKUP_NAME}-db.tar.gz -C /volume .

  echo "[INFO] Criando backup do volume do EJBCA ($EJBCA_VOLUME)..."
  docker run --rm -v ${EJBCA_VOLUME}:/volume -v "$BACKUP_DIR":/backup alpine \
    tar czf /backup/${BACKUP_NAME}-ejbca.tar.gz -C /volume .

  echo "[OK] Backup concluído: $BACKUP_DIR"
}

# Função de restauração
restore() {
  BACKUP_FOLDER="$1"
  [ -z "$BACKUP_FOLDER" ] && echo "[ERRO] Diretório de backup não informado." && usage

  echo "[INFO] Parando os serviços..."
  docker compose -f "$COMPOSE_FILE" down -v

  echo "[INFO] Removendo volumes antigos..."
  docker volume rm ${DB_VOLUME} ${EJBCA_VOLUME}

  echo "[INFO] Restaurando volume do banco de dados..."
  docker volume create ${DB_VOLUME}
  docker run --rm -v ${DB_VOLUME}:/volume -v "$BACKUP_FOLDER":/backup alpine \
    tar xzf /backup/*-db.tar.gz -C /volume

  echo "[INFO] Restaurando volume do EJBCA..."
  docker volume create ${EJBCA_VOLUME}
  docker run --rm -v ${EJBCA_VOLUME}:/volume -v "$BACKUP_FOLDER":/backup alpine \
    tar xzf /backup/*-ejbca.tar.gz -C /volume

  echo "[INFO] Iniciando os serviços..."
  docker compose -f "$COMPOSE_FILE" up -d

  echo "[OK] Restauração concluída."
}

# Interpreta a opção fornecida
case "$1" in
  backup)
    backup
    ;;
  restore)
    restore "$2"
    ;;
  *)
    usage
    ;;
esac

!/bin/bash

# Diretório de backup ajustado para ambiente com permissão de escrita
BACKUP_DIR="/home/backup/ejbca"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_NAME="ejbca-backup-$TIMESTAMP"
DB_VOLUME="db_data"
EJBCA_VOLUME="ejbca_data"
COMPOSE_FILE="docker-compose.yml"  # Ajuste o caminho se estiver fora do diretório atual

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
  echo "Parando os serviços..."
  docker compose -f "$COMPOSE_FILE" down

  echo "Criando backup do volume do banco de dados ($DB_VOLUME)..."
  docker run --rm -v ${DB_VOLUME}:/volume -v "$BACKUP_DIR":/backup alpine tar czf /backup/${BACKUP_NAME}-db.tar.gz -C /volume .

  echo "Criando backup do volume do EJBCA ($EJBCA_VOLUME)..."
  docker run --rm -v ${EJBCA_VOLUME}:/volume -v "$BACKUP_DIR":/backup alpine tar czf /backup/${BACKUP_NAME}-ejbca.tar.gz -C /volume .

  echo "Backup concluído: $BACKUP_DIR"
}

restore() {
  BACKUP_FOLDER="$1"
  [ -z "$BACKUP_FOLDER" ] && echo "Erro: diretório de backup não informado." && usage

  echo "Parando os serviços..."
  docker compose -f "$COMPOSE_FILE" down -v

  echo "Removendo volumes antigos..."
  docker volume rm ${DB_VOLUME} ${EJBCA_VOLUME}

  echo "Restaurando volume do banco de dados..."
  docker volume create ${DB_VOLUME}
  docker run --rm -v ${DB_VOLUME}:/volume -v "$BACKUP_FOLDER":/backup alpine tar xzf /backup/*-db.tar.gz -C /volume

  echo "Restaurando volume do EJBCA..."
  docker volume create ${EJBCA_VOLUME}
  docker run --rm -v ${EJBCA_VOLUME}:/volume -v "$BACKUP_FOLDER":/backup alpine tar xzf /backup/*-ejbca.tar.gz -C /volume

  echo "Iniciando os serviços..."
  docker compose -f "$COMPOSE_FILE" up -d

  echo "Restauração concluída."
}

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

                                         

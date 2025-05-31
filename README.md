# EJBCA - Infraestrutura com Docker Compose (Ambiente de Produção)

Este repositório define a infraestrutura de uma autoridade certificadora EJBCA Community Edition em ambiente Docker, preparada para produção, com suporte a backup, restauração e práticas seguras de manutenção.

---

## 📁 Estrutura de Diretórios

```text
/srv/ejbca/
├── containers/                          # Infraestrutura Docker
│   ├── docker-compose.yml              # Compose principal (versões fixas)
│   ├── .env                             # Variáveis sensíveis (usuário, senha, DB)
│   └── scripts/                         # Scripts auxiliares
│       ├── ejbca-backup-restore.sh      # Backup e restore dos volumes
│       ├── limpar-docker.sh             # Limpeza de imagens, volumes e containers
│       └── install-docker-compose-v2.sh # Instalação do Docker Compose V2
├── backups/                             # Backups gerados
│   └── ejbca/                           # Backups versionados (data/hora)
│       ├── ejbca-backup-20240531-143012-db.tar.gz
│       └── ejbca-backup-20240531-143012-ejbca.tar.gz
├── logs/                                # Logs persistentes
│   ├── ejbca/                           # Logs da aplicação EJBCA
│   └── database/                        # Logs do MariaDB
└── certs/                               # (opcional) Certificados TLS externos

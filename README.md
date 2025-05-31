/home/inageadmin/
├── containers/                          # Infraestrutura Docker
│   ├── docker-compose.yaml              # Compose principal
│   ├── .env                             # Variáveis de ambiente (com senha do banco etc.)
│   └── scripts/                         # Scripts auxiliares
│       ├── ejbca-backup-restore.sh      # Backup e restore dos volumes
│       └── monitor.sh                   # (opcional) script de healthcheck/logs/etc.
├── backups/                             # Backups gerados
│   └── ejbca/                           # Backups versionados (data/hora)
│       ├── db_data.tar.gz
│       └── ejbca_data.tar.gz
├── logs/                                # Logs persistentes
│   ├── ejbca/                           # Logs de aplicação
│   └── database/                        # Logs do banco
└── certs/                               # (opcional) certificados TLS externos

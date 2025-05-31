# EJBCA - Infraestrutura com Docker Compose (Ambiente de Produção)

Este projeto define uma infraestrutura segura e reutilizável do EJBCA Community Edition em ambiente Docker, com práticas voltadas à produção, incluindo backup, restauração e organização modular.

---

## ✅ Requisitos

- Ubuntu Server 22.04 LTS
- Docker instalado via `apt` (não via Snap)
- Docker Compose V2 (como plugin CLI)
- Acesso root ou permissões de `sudo`

---

## 📂 Estrutura de Diretórios

```
/srv/ejbca/
├── containers/
│   ├── docker-compose.yml              # Compose principal com versões fixas
│   ├── .env                            # Variáveis sensíveis (usuários, senhas, banco)
│   └── scripts/
│       ├── ejbca-backup-restore.sh     # Script de backup e restore
│       ├── limpar-docker.sh            # Limpeza de volumes, containers e imagens
│       └── installdocker-compose-v2.sh # Instalação manual do Docker Compose V2
├── backups/
│   └── ejbca/                          # Backups versionados com data/hora
├── logs/
│   ├── ejbca/                          # Logs da aplicação EJBCA
│   └── database/                       # Logs do banco de dados MariaDB
└── certs/                              # (opcional) Certificados TLS externos
```

---

## 🔐 Arquivo `.env`

Contém credenciais e configurações do banco:

- `MYSQL_ROOT_PASSWORD`
- `MYSQL_DATABASE`
- `MYSQL_USER`
- `MYSQL_PASSWORD`

---

## 🐳 docker-compose.yml

- Usa imagens com versões fixas (`keyfactor/ejbca-ce:8.0.0` e `mariadb:10.11.13`)
- Define healthcheck no banco
- Expõe apenas a porta 443 (HTTPS)
- Volumes persistentes: `db_data` e `ejbca_data`
- Redes isoladas: `access-bridge` e `application-bridge`
- Logging configurado para produção

---

## 🧪 Backup e Restore

O script `ejbca-backup-restore.sh` permite:

- Parar os serviços
- Criar `.tar.gz` de ambos os volumes
- Restaurar volumes a partir de backups anteriores
- Manter o ambiente íntegro após desastres

Backups são armazenados em:

```
/srv/ejbca/backups/ejbca/
```

---

## ⚙️ Instalação do Docker Compose V2

Caso o Compose não esteja disponível (comando `docker compose`), utilize o script `installdocker-compose-v2.sh` para:

- Criar a pasta de plugins CLI
- Fazer o download do binário do Compose V2
- Torná-lo executável

---

## 🧹 Limpeza do Docker

O script `limpar-docker.sh` remove:

- Todos os containers
- Volumes não utilizados
- Imagens antigas

Use com cautela, principalmente em ambientes de produção.

---

## 🚀 Executando o Projeto

1. Acesse o diretório do projeto:

```bash
cd /srv/ejbca/containers
```

2. Inicie os serviços:

```bash
docker compose up -d
```

---

## 🧩 Comandos úteis

- Criar backup:

```bash
./scripts/ejbca-backup-restore.sh backup
```

- Restaurar de backup:

```bash
./scripts/ejbca-backup-restore.sh restore /srv/ejbca/backups/ejbca
```

---

## 👨‍💻 Filosofia de Código

Este projeto segue princípios inspirados por:

- **Guido van Rossum** – legibilidade, simplicidade e clareza
- **Linus Torvalds** – confiabilidade, modularidade e controle total
- **Steve Wozniak** – engenharia precisa, autonomia e excelência técnica

---

## 📦 Futuras melhorias

- Monitoramento com Prometheus ou Grafana
- Integração com sistema de alertas
- Backup automatizado via cron

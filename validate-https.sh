#!/bin/bash
echo "[INFO] Testando conexão HTTPS no container EJBCA..."
docker exec -it ejbca curl -k https://localhost:8443/ejbca/adminweb || echo "Erro: HTTPS não está escutando."

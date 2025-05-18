#!/bin/bash
echo "[INFO] Inicializando token no SoftHSM..."
docker exec -it softhsm softhsm2-util --init-token --slot 0 --label "EJBCA" --pin 1234 --so-pin 1234

echo "[INFO] Validando token..."
docker exec -it softhsm softhsm2-util --show-slots

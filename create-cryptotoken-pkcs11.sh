#!/bin/bash

EJBCA_URL="https://10.224.144.138/ejbca/ejbca-rest-api"
ADMIN_USERNAME="superadmin"
ADMIN_PASSWORD="supersenha" # Ajuste conforme sua senha real do usuário SuperAdmin no EJBCA

TOKEN_NAME="HSM-Token"
PKCS11_PIN="1234"
PKCS11_SLOT="0"
PKCS11_MODULE_PATH="/usr/lib/x86_64-linux-gnu/softhsm/libsofthsm2.so"

curl -k -X POST "${EJBCA_URL}/v1/cryptotokens" \
  -u "${ADMIN_USERNAME}:${ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "'"${TOKEN_NAME}"'",
    "type": "PKCS11",
    "autoActivate": true,
    "properties": "slot='${PKCS11_SLOT}';library='${PKCS11_MODULE_PATH}';attributesFile=",
    "authenticationCode": "'${PKCS11_PIN}'"
  }'

#!/bin/sh
set -e

# Define as variáveis, lendo do ambiente
KEYCLOAK_URL="http://keycloak:8080"
REALM_NAME="poupe-ai"
# A variável KEYCLOAK_ISSUER é passada pelo Docker Compose
JWKS_URL="${KEYCLOAK_URL}/realms/${REALM_NAME}/protocol/openid-connect/certs"
KONG_CONFIG_TEMPLATE="/opt/kong/kong.template.yaml"
KONG_CONFIG_FINAL="/opt/kong/kong.yaml"

# 1. Espera o Keycloak ficar disponível
echo "Aguardando o Keycloak em ${KEYCLOAK_URL}..."
until curl --output /dev/null --silent --head --fail ${KEYCLOAK_URL}/realms/${REALM_NAME}; do
  printf '.'
  sleep 5
done
echo -e "\nKeycloak está pronto."

# 2. Gera a chave PEM a partir do JWKS
echo "Gerando chave PEM a partir de ${JWKS_URL}..."
PEM_KEY=$(python3 /scripts/generate_pem.py ${JWKS_URL})
if [ -z "${PEM_KEY}" ]; then
  echo "Falha ao gerar a chave PEM. Abortando."
  exit 1
fi
echo "Chave PEM gerada com sucesso."

# 3. Processa o template fazendo as substituições
echo "Configurando o kong.yaml..."

# Primeiro, captura a indentação da linha do placeholder da chave pública
INDENTATION=$(grep "__KEYCLOAK_RSA_PUBLIC_KEY__" ${KONG_CONFIG_TEMPLATE} | sed 's/\(__KEYCLOAK_RSA_PUBLIC_KEY__\).*//')

# Prepara a chave PEM com a indentação correta
INDENTED_PEM_KEY=$(echo "${PEM_KEY}" | sed "s/^/${INDENTATION}/")

# Cria um arquivo temporário com a chave PEM indentada
echo "${INDENTED_PEM_KEY}" > /tmp/pem_key.txt

# Agora, substitui os placeholders no template:
# - O primeiro 'sed' substitui o placeholder da chave pública
# - O segundo 'sed' substitui o placeholder do issuer
sed -e "/__KEYCLOAK_RSA_PUBLIC_KEY__/r /tmp/pem_key.txt" -e "/__KEYCLOAK_RSA_PUBLIC_KEY__/d" ${KONG_CONFIG_TEMPLATE} | \
  sed "s|__KEYCLOAK_ISSUER_URL__|${KEYCLOAK_ISSUER}|g" > ${KONG_CONFIG_FINAL}


# Limpa o arquivo temporário
rm /tmp/pem_key.txt

echo "Configuração do Kong finalizada. Iniciando Kong..."

# 4. Inicia o processo do Kong
exec kong start
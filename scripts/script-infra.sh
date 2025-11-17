#!/bin/bash

# Configurações
RESOURCE_GROUP="MetaFlowGroup"
LOCATION="brazilsouth"
SQL_SERVER="metaflow-sql-server"
SQL_DB="metaflow-db"
SQL_ADMIN_USER="metaflowadmin"
ACR_NAME="metaflowacr"
ACI_NAME="metaflow-app"

echo "=== CRIANDO RECURSOS AZURE PARA METAFLOW ==="

# 1. Criar Resource Group
echo "Criando Resource Group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# 2. Criar Azure Container Registry (ACR)
echo "Criando Azure Container Registry..."
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --admin-enabled true

# 3. Criar SQL Server
echo "Criando SQL Server..."
az sql server create \
    --resource-group $RESOURCE_GROUP \
    --name $SQL_SERVER \
    --location $LOCATION \
    --admin-user $SQL_ADMIN_USER \
    --admin-password "TempPassword123!"

# 4. Configurar firewall para permitir conexões Azure
echo "Configurando firewall do SQL Server..."
az sql server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER \
    --name AllowAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

# 5. Criar Banco de Dados
echo "Criando Banco de Dados..."
az sql db create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER \
    --name $SQL_DB \
    --service-objective Basic \
    --max-size 2GB

# 6. Obter informações de conexão
echo "=== INFORMAÇÕES DE CONEXÃO ==="
echo "SQL Server: $SQL_SERVER.database.windows.net"
echo "Database: $SQL_DB"
echo "ACR: $ACR_NAME.azurecr.io"

# 7. Mostrar status dos recursos
echo "=== STATUS DOS RECURSOS ==="
az resource list --resource-group $RESOURCE_GROUP --output table

echo "=== RECURSOS CRIADOS COM SUCESSO! ==="
#!/bin/bash
echo "=== PROVISIONAMENTO WEB APP + AZURE SQL ==="

# Resource Group (com verificação)
if ! az group show --name MetaFlowGroup &>/dev/null; then
    echo "Criando Resource Group..."
    az group create --name MetaFlowGroup --location brazilsouth
else
    echo "Resource Group já existe."
fi

# SQL Server (com verificação)
if ! az sql server show --name metaflow-sql-server-rm557702 --resource-group MetaFlowGroup &>/dev/null; then
    echo "Criando SQL Server..."
    az sql server create \
        --resource-group MetaFlowGroup \
        --name metaflow-sql-server-rm557702 \
        --location brazilsouth \
        --admin-user metaflowadmin \
        --admin-password "Michele2006@"
else
    echo "SQL Server já existe."
fi

# Firewall Rule (sempre recriar se necessário)
echo "Configurando firewall..."
az sql server firewall-rule create \
    --resource-group MetaFlowGroup \
    --server metaflow-sql-server-rm557702 \
    --name AllowAll \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 255.255.255.255 \
    --output none

# SQL Database (com verificação)
if ! az sql db show --name metaflow-db --server metaflow-sql-server-rm557702 --resource-group MetaFlowGroup &>/dev/null; then
    echo "Criando SQL Database..."
    az sql db create \
        --resource-group MetaFlowGroup \
        --server metaflow-sql-server-rm557702 \
        --name metaflow-db \
        --service-objective Basic \
        --max-size 2GB
else
    echo "SQL Database já existe."
fi

# App Service Plan (com verificação)
if ! az appservice plan show --name MetaFlowPlan --resource-group MetaFlowGroup &>/dev/null; then
    echo "Criando App Service Plan..."
    az appservice plan create \
        --name MetaFlowPlan \
        --resource-group MetaFlowGroup \
        --sku B1 \
        --is-linux
else
    echo "App Service Plan já existe."
fi

# Web App (com verificação)
if ! az webapp show --name metaflow-app-rm557702 --resource-group MetaFlowGroup &>/dev/null; then
    echo "Criando Web App..."
    az webapp create \
        --name metaflow-app-rm557702 \
        --resource-group MetaFlowGroup \
        --plan MetaFlowPlan \
        --runtime "JAVA:21-java21"
else
    echo "Web App já existe."
fi

# App Settings (sempre atualizar)
echo "Configurando variáveis de ambiente..."
az webapp config appsettings set \
    --name metaflow-app-rm557702 \
    --resource-group MetaFlowGroup \
    --settings \
    SPRING_DATASOURCE_URL="jdbc:sqlserver://metaflow-sql-server-rm557702.database.windows.net:1433;database=metaflow-db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;" \
    SPRING_DATASOURCE_USERNAME="metaflowadmin" \
    SPRING_DATASOURCE_PASSWORD="Michele2006@" \
    SPRING_JPA_HIBERNATE_DDL_AUTO="update" \
    --output none

echo "=== INFRAESTRUTURA CONFIGURADA COM SUCESSO ==="
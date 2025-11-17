#!/bin/bash
echo "=== DEPLOY NO AZURE CONTAINER INSTANCE ==="

# Obter password do ACR
ACR_PASSWORD=$(az acr credential show --name metaflowacrrm557702 --query "passwords[0].value" --output tsv)

# Criar Container Instance
az container create \
    --resource-group MetaFlowGroup \
    --name metaflow-container-$BUILD_ID \
    --image metaflowacrrm557702.azurecr.io/metaflow-app:latest \
    --cpu 1 \
    --memory 1.5 \
    --ports 8080 \
    --ip-address Public \
    --registry-username metaflowacrrm557702 \
    --registry-password $ACR_PASSWORD \
    --environment-variables \
        SPRING_DATASOURCE_URL="$DATABASE_URL" \
        SPRING_DATASOURCE_USERNAME="$DATABASE_USERNAME" \
        SPRING_DATASOURCE_PASSWORD="$DATABASE_PASSWORD" \
        SPRING_JPA_HIBERNATE_DDL_AUTO="update" \
        SPRINGDOC_SWAGGER_UI_ENABLED="true" \
    --dns-name-label metaflow-$BUILD_ID

echo "=== CONTAINER INSTANCE CRIADO ==="
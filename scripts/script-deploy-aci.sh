#!/bin/bash
echo "=== DEPLOY NO AZURE CONTAINER INSTANCE ==="

ACR_PASSWORD=$(az acr credential show --name metaflowacrrm557702 --query "passwords[0].value" --output tsv)

CONTAINER_NAME="metaflow-container-$(Build.BuildId)"
DNS_LABEL="metaflow-$(Build.BuildId)"

EXISTING_CONTAINER=$(az container show --name $CONTAINER_NAME --resource-group MetaFlowGroup --query "name" --output tsv 2>/dev/null)

if [ -n "$EXISTING_CONTAINER" ]; then
    echo " Container $CONTAINER_NAME já existe. Parando e removendo..."
    az container delete --name $CONTAINER_NAME --resource-group MetaFlowGroup --yes
    echo " Container antigo removido."
fi

echo "Criando Container Instance..."
az container create \
    --resource-group MetaFlowGroup \
    --name $CONTAINER_NAME \
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
    --dns-name-label $DNS_LABEL

echo "===  CONTAINER INSTANCE CRIADO ==="
echo "URL: http://$DNS_LABEL.brazilsouth.azurecontainer.io:8080"
echo "Swagger: http://$DNS_LABEL.brazilsouth.azurecontainer.io:8080/swagger-ui.html"
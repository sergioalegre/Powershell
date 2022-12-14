######################################
##########     AZ CLI     ############
######################################

az account set --subscription "SUSCRIPTION_NAME_HERE"
RESOURCE_GROUP_ORIGEN="rg-source"
RESOURCE_GROUP_REPO_TEMPLATES="rg-destination"

#1:exportar:
az group export --name $RESOURCE_GROUP_ORIGEN > $RESOURCE_GROUP_ORIGEN.json

#2:importar (OPCIONAL):
# az deployment group create \
#   --name $RESOURCE_GROUP \
#   --resource-group RESOURCE_GROUP_REPO_TEMPLATES \
#   --template-file $RESOURCE_GROUP.json

#3:convertir en template spec:
az ts create --name $RESOURCE_GROUP_ORIGEN --version "1.0" --resource-group $RESOURCE_GROUP_REPO_TEMPLATES --location "westeurope" --template-file $RESOURCE_GROUP_ORIGEN.json


######################################
##########   POWERSHELL   ############
######################################

az account set --subscription "SUSCRIPTION_NAME_HERE"
$RESOURCE_GROUP_ORIGEN="rg-source"
$RESOURCE_GROUP_REPO_TEMPLATES="rg-destination"

#0:login:
az login 
#entidad de servicio (service principal):
#az login --service-principal -u <app-id> -p <password-or-cert> --tenant <tenant>

#1:exportar:
az group export --name $RESOURCE_GROUP_ORIGEN > C:\TEMP\$RESOURCE_GROUP_ORIGEN.json

#2:importar (OPCIONAL):
#az deployment group create --name $RESOURCE_GROUP_ORIGEN --resource-group $RESOURCE_GROUP_REPO_TEMPLATES --template-file  "C:\TEMP\$RESOURCE_GROUP_ORIGEN.json" --parameters storageAccountType=Standard_GRS

#3:convertir en template spec:
#3.1 upload del JSON a Azure
#3.2 convertir en template spec
az ts create --name $RESOURCE_GROUP --version "1.0" --resource-group $RESOURCE_GROUP_REPO_TEMPLATES --location "westeurope" --template-file $RESOURCE_GROUP.json
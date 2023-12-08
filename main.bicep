param containerRegistryName string
param location string 
param appServicePlanName string
param webAppName string ='crstinareq ex3 webapp'
param containerRegistryImageName string = 'flask-demo'
param containerRegistryImageVersion string = 'latest'
@secure()
param DOCKER_REGISTRY_SERVER_PASSWORD string
param DOCKER_REGISTRY_SERVER_USERNAME string 
param DOCKER_REGISTRY_SERVER_URL string  

//param kevVaultSecretNameACRUsername string = 'acr-username'
//param kevVaultSecretNameACRPassword1 string = 'acr-password1'
//param kevVaultSecretNameACRPassword2 string = 'acr-password2'

//resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  //name: keyVaultName
//}
// Deploy Azure Container Registry

module containerRegistry 'ResourceModules-main/modules/container-registry/registry/main.bicep' = {
  //dependsOn: [
    //keyvault
  //]
  name: containerRegistryName
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true

    //adminCredentialsKeyVaultResourceId: resourceId('Microsoft.KeyVault/vaults', keyVaultName)
    //adminCredentialsKeyVaultSecretUserName: kevVaultSecretNameACRUsername
    //adminCredentialsKeyVaultSecretPassword1: kevVaultSecretNameACRPassword1
    //adminCredentialsKeyVaultSecretPassword2: kevVaultSecretNameACRPassword2
  }
}

module serverfarm 'ResourceModules-main/modules/web/serverfarm/main.bicep' = {
  name: appServicePlanName
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    reserved: true
  }
}

module website 'ResourceModules-main/modules/web/site/main.bicep' =  {
  name: webAppName
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: serverfarm.outputs.resourceId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName }:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DOCKER_REGISTRY_SERVER_URL: DOCKER_REGISTRY_SERVER_URL
      DOCKER_REGISTRY_SERVER_USERNAME:  DOCKER_REGISTRY_SERVER_USERNAME
      DOCKER_REGISTRY_SERVER_PASSWORD: DOCKER_REGISTRY_SERVER_PASSWORD
    }
  }
}

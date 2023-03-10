@description('Environment Name: shared/dev / stg /prod')
param envName string

@description('Pirmary Azure Region name in short')
param regionsuffix string

param location string = resourceGroup().location

var KeyVault_Name = 'kv-rl-${envName}-aro-${regionsuffix}'

resource KeyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: KeyVault_Name
  location: location
  tags: resourceGroup().tags
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enablePurgeProtection: true
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

param storageName array = [
  {
    Name: 'rlsansglogprdaro'
    existingNSG1: 'app'
    existingNSG2: 'db'
    existingNSG3: 'pep'
    existingNSG4: 'web'
  }
  {
    Name: 'rlsansglognpdaro'
    existingNSG1: 'app'
    existingNSG2: 'db'
    existingNSG3: 'pep'
    existingNSG4: 'web'
  }
]

@description('Pirmary Azure Region name in short')
param storageregion string

param location string = resourceGroup().location

resource storageName_Name_storageregion 'Microsoft.Storage/storageAccounts@2021-04-01' = [for item in storageName: {
  name: '${toLower(item.Name)}${storageregion}'
  properties: {
    allowCrossTenantReplication: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Deny'
    }
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
    }
   }
  location: location
  tags: resourceGroup().tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
    
  }
}]

resource storageName_Name_storageregion_default 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = [for item in storageName: {
  name: '${toLower(item.Name)}${storageregion}/default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
  }
  dependsOn: [
    storageName_Name_storageregion
  ]
}]

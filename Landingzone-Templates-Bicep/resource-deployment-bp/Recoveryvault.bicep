@description('Environment Name: shared/dev / stg /prod')
param envName string

@description('Pirmary Azure region name in short')
param regionsuffix string

@description('Storage replication type for Recovery Services vault')
@allowed([
  'LocallyRedundant'
  'GeoRedundant'
  'ReadAccessGeoZoneRedundant'
  'ZoneRedundant'
])
param storageType string = 'GeoRedundant'

param location string = resourceGroup().location

@description('Enable cross region restore')
param enablecrossRegionRestore bool = true

@description('Diagnostic Name suggest to send all the logs to Log analytics workspace. Only required if enableDiagnostics is set to true.')
param diagnosticsName string = 'Send To Log Analytics'

@description('Hub Subscription ID')
param hubsubscriptionID string

var recoveryvaultnamevar = 'rsv-rl-${envName}-aro-bkp-${regionsuffix}'
var hub_LA_resource_group = 'rg-${envName}-aro-loganalytics-${regionsuffix}'
var logAnalyticsWorkspaceName = 'la-rl-${envName}-aro-${regionsuffix}'

resource recoveryvaultname 'Microsoft.RecoveryServices/vaults@2022-04-01' = {
  name: recoveryvaultnamevar
  location: location
  tags: resourceGroup().tags
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {
  }
}

resource recoveryvaultname_VaultStorageConfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2021-04-01' = {
  parent: recoveryvaultname
  name: 'vaultstorageconfig'
  properties: {
    crossRegionRestoreFlag: enablecrossRegionRestore
    storageType: storageType
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  scope: recoveryvaultname
  name: diagnosticsName
  properties: {
    workspaceId: resourceId(hubsubscriptionID, hub_LA_resource_group, 'Microsoft.OperationalInsights/workspaces', logAnalyticsWorkspaceName)
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'CoreAzureBackup'
        enabled: true
      }
      {
        category: 'AddonAzureBackupJobs'
        enabled: true
      }
      {
        category: 'AddonAzureBackupAlerts'
        enabled: true
      }
      {
        category: 'AddonAzureBackupPolicy'
        enabled: true
      }
      {
        category: 'AddonAzureBackupStorage'
        enabled: true
      }
      {
        category: 'AddonAzureBackupProtectedInstance'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Health'
        enabled: true
      }
    ]
  }
}

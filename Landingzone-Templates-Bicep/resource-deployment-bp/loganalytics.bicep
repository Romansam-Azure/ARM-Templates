metadata generator = {
  name: 'bicepdf'
  version: '0.4.1124.51302'
  templateHash: '927733442062678948'
}

@description('Environment Name: dev / stg /prod')
param envName string

@description('Pirmary Azure Region name in short')
param regionsuffix string

@description('Pirmary Azure Region name in short')
param region string

param location string = resourceGroup().location

var automationAccountName = 'aac-rl-${envName}-aro-${regionsuffix}'
var automationAccountsRG = 'rg-${envName}-aro-automation-${region}'
var LogAnalyticsWorkspacename = 'la-rl-${envName}-aro-${regionsuffix}'

resource LogAnalyticsWorkspacenam 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: LogAnalyticsWorkspacename
  location: location
  tags: resourceGroup().tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource LogAnalyticsWorkspacename_Automation 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  parent: LogAnalyticsWorkspacenam
  name: 'Automation'
  tags: resourceGroup().tags
  properties: {
    resourceId: resourceId(automationAccountsRG, 'Microsoft.Automation/automationAccounts', automationAccountName)
  }
}

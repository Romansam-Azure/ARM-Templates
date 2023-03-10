param location string = resourceGroup().location


@description('Environment Name: dev / stg /prod')
param envName string

@description('Pirmary Azure Region name in short')
param regionsuffix string
param sampleGraphicalRunbookName string = 'AzureAutomationTutorial'
param sampleGraphicalRunbookDescription string = 'An example runbook that gets all the Resource Manager resources by using the Run As account (service principal).'
param samplePowerShellRunbookName string = 'AzureAutomationTutorialScript'
param samplePowerShellRunbookDescription string = 'An example runbook that gets all the Resource Manager resources by using the Run As account (service principal).'
param samplePython2RunbookName string = 'AzureAutomationTutorialPython2'
param samplePython2RunbookDescription string = 'An example runbook that gets all the Resource Manager resources by using the Run As account (service principal).'

@description('URI to artifacts location')
param _artifactsLocation string = 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.automation/101-automation/azuredeploy.json'

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated')
@secure()
param _artifactsLocationSasToken string = ''

var automationAccountName = 'aac-rl-${envName}-aro-${regionsuffix}'

resource automationAccount 'Microsoft.Automation/automationAccounts@2020-01-13-preview' = {
  name: automationAccountName
  location: location
  tags: resourceGroup().tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

resource automationAccountName_sampleGraphicalRunbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  parent: automationAccount
  name: sampleGraphicalRunbookName
  location: location
  tags: resourceGroup().tags
  properties: {
    runbookType: 'GraphPowerShell'
    logProgress: false
    logVerbose: false
    description: sampleGraphicalRunbookDescription
    publishContentLink: {
      uri: uri(_artifactsLocation, 'scripts/AzureAutomationTutorial.graphrunbook${_artifactsLocationSasToken}')
      version: '1.0.0.0'
    }
  }
}

resource automationAccountName_samplePowerShellRunbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  parent: automationAccount
  name: samplePowerShellRunbookName
  location: location
  tags: resourceGroup().tags
  properties: {
    runbookType: 'PowerShell'
    logProgress: false
    logVerbose: false
    description: samplePowerShellRunbookDescription
    publishContentLink: {
      uri: uri(_artifactsLocation, 'scripts/AzureAutomationTutorial.ps1${_artifactsLocationSasToken}')
      version: '1.0.0.0'
    }
  }
}

resource automationAccountName_samplePython2Runbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  parent: automationAccount
  name: samplePython2RunbookName
  location: location
  tags: resourceGroup().tags
  properties: {
    runbookType: 'Python2'
    logProgress: false
    logVerbose: false
    description: samplePython2RunbookDescription
    publishContentLink: {
      uri: uri(_artifactsLocation, 'scripts/AzureAutomationTutorialPython2.py${_artifactsLocationSasToken}')
      version: '1.0.0.0'
    }
  }
}

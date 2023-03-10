targetScope = 'subscription'
param resourceTags object = {
  CostCenter: ''
  Environment: ''
  ApplicationName: ''
  ApplicationType: ''
  Owner: 'Retirement Living'
  Criticality: ''
  Department: ''
  MaintenanceWindow: ''
  DataClassification: 'Sensitive'
  BackupPlan: ''
}
param location string
param envName string
param list array = [
  'network'
  'servers'
  'storage'
  'automation'
  'loganalytics'
]
param region string


resource resourcegroupbp1 'Microsoft.Resources/resourceGroups@2022-09-01' = [for name in list: {
  name: 'rg-${envName}-aro-${name}-${region}'
  location: location
  tags: resourceTags
  
}]

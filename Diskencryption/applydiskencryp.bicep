param vmName string
param keyVaultName string
param keyVaultResourceGroup string
param keyEncryptionKeyURL string
param location string
var extensionName = 'AzureDiskEncryption'
var keyVaultResourceID = resourceId(keyVaultResourceGroup, 'Microsoft.KeyVault/vaults/', keyVaultName)
resource DiskEncryption 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  name: '${vmName}/${extensionName}'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'AzureDiskEncryption'
    typeHandlerVersion: '2.2'
    autoUpgradeMinorVersion: true
    forceUpdateTag: '1.0'
    settings: {
      EncryptionOperation: 'EnableEncryption'
      KeyVaultURL: reference(keyVaultResourceID, '2019-09-01').vaultUri
      KeyVaultResourceId: keyVaultResourceID
      KeyEncryptionKeyURL: keyEncryptionKeyURL
      KekVaultResourceId: keyVaultResourceID
      KeyEncryptionAlgorithm: 'RSA-OAEP'
      VolumeType: 'All'
      ResizeOSDisk: false
    }
  }
}
param Keyvaultname string
param vmssName string
param location string

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: Keyvaultname
}

module virtualmachinescaleset 'rrianvmssazkv.bicep' = {
  name: vmssName

  params: { 
    location: location
    adminPasswordkv: keyvault.getSecret('virtualm') 
  }
}

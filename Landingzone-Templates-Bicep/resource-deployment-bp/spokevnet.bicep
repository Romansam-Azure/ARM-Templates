param routetablecustom array = [
  {
    Name: 'pep'
  }
  {
    Name: 'web'
  }
  {
    Name: 'app'
  }
  {
    Name: 'db'
  }
]
param nsgName array = [
  {
    Name: 'pep'
  }
  {
    Name: 'web'
  }
  {
    Name: 'app'
  }
  {
    Name: 'db'
  }
]
param subnetsConfiguration array = [
  {
    name: 'pep'
    snetaddressSuffix: '.1.128/27'
    nsgSuffix: 'pep'
    routeTableSuffix: 'pep'
  }
  {
    name: 'web'
    snetaddressSuffix: '.1.0/26'
    nsgSuffix: 'web'
    routeTableSuffix: 'web'
  }
  {
    name: 'app'
    snetaddressSuffix: '.0.0/26'
    nsgSuffix: 'app'
    routeTableSuffix: 'app'
  }
  {
    name: 'db'
    snetaddressSuffix: '.1.64/26'
    nsgSuffix: 'db'
    routeTableSuffix: 'db'
  }
]

@description('Environment Name: dev / stg /prod')
param envName string

@description('Pirmary Azure regionsuffix name in short')
param regionsuffix string

@description('Pirmary Azure region name in short - aue')
param region string

@metadata({ discription: 'Spoke Vnet Address space' })
param spoke_vnet_address_prefix string

@metadata({ descriptoin: 'Hub Vnet name' })
param hub_vnet_name string

@metadata({ descriptoin: 'hub-vnet-resource-group' })
param hub_vnet_resource_group string

@metadata({ descriptoin: 'Hub Vnet Subscription ID' })
param hub_subscriptionID string

param location string = resourceGroup().location

var spokevnetname = 'vnet-${envName}-dfj-${regionsuffix}'
var peering_name_spoke_to_hub_one = '${envName}-dfj-${region}-spoke-to-hub-${region}-vnet-peering'
var nsgNameprefix = 'nsg-snet-${envName}-dfj-'
var routetableprefix = 'rt-snet-${envName}-dfj-'
var subnetprefix_ = 'snet-${envName}-dfj-'
var diskaccessgroup = 'dag-${envName}-dfj-${regionsuffix}'

resource routetableprefix_routetablecustom_Name_regionsuffix 'Microsoft.Network/routeTables@2020-11-01' = [for item in routetablecustom: {
  name: '${routetableprefix}${toLower(item.Name)}-${regionsuffix}'
  location: location
  tags: resourceGroup().tags
  properties: {
    disableBgpRoutePropagation: false
    routes: []
  }
}]

resource nsgNameprefix_nsgName_Name_regionsuffix 'Microsoft.Network/networkSecurityGroups@2020-03-01' = [for item in nsgName: {
  name: '${nsgNameprefix}${toLower(item.Name)}-${regionsuffix}'
  location: location
  tags: resourceGroup().tags
  properties: {
    securityRules: []
  }
}]

resource diskaccessgroupvar 'Microsoft.Compute/diskAccesses@2021-12-01' = {
  name: diskaccessgroup
  location: location
  tags: resourceGroup().tags
  properties: {
  }
}

resource spoke_vnet_name 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: spokevnetname
  location: location
  tags: resourceGroup().tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${spoke_vnet_address_prefix}.0.0/22'
      ]
    }
    subnets: [for item in subnetsConfiguration: {
      name: '${subnetprefix_}${toLower(item.name)}-${regionsuffix}'
      properties: {
        addressPrefix:'${spoke_vnet_address_prefix}${subnetsConfiguration}${toLower(item.snetaddressSuffix)}'
        routeTable: {
          id: resourceId('Microsoft.Network/routeTables', '${routetableprefix}${toLower(item.routeTableSuffix)}-${regionsuffix}')
        }
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Disabled'
        networkSecurityGroup: {
          id: resourceId('Microsoft.Network/networkSecurityGroups', '${nsgNameprefix}${toLower(item.nsgSuffix)}-${regionsuffix}')
        }
        serviceEndpoints: [
          {
            service: 'Microsoft.Sql'
            locations: [
              location
            ]
          }
          {
            service: 'Microsoft.Storage'
            locations: [
              location
            ]
          }
          {
            service: 'Microsoft.EventHub'
            locations: [
              location
            ]
          }
          {
            service: 'Microsoft.KeyVault'
            locations: [
              location
            ]
          }
          {
            service: 'Microsoft.AzureActiveDirectory'
            locations: [
              location
            ]
          }
        ]
      }
    }]
  }
}

resource spoke_vnet_name_peering_name_spoke_to_hub_one 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-01-01' = {
  parent: spoke_vnet_name
  name: '${spoke_vnet_name}${peering_name_spoke_to_hub_one}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId(hub_subscriptionID, hub_vnet_resource_group, 'Microsoft.Network/virtualNetworks', hub_vnet_name)
    }
    remoteAddressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    remoteVirtualNetworkAddressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    }
}

param resourceTags object = resourceGroup().tags

@description('Environment Name')
param envName string
param location string = resourceGroup().location

@description('Pirmary Azure Region name in short')
param regionsuffix string

@metadata({ discription: 'Shared Vnet Address range' })
param hub_vnet_address_prefix string
param nsgName array = [
  {
    Name: 'pep'
  }
  {
    Name: 'arosvs'
  }
  {
    Name: 'mgmt'
  }
]
param routetablecustom array = [
  {
  Name:'pep'               
  }
  {
  Name:'arosvs'              
  }
  {
  Name:'mgmt'           
  }  
]
param routetable array = [
  {
  Name:'GatewaySubnet'               
  }
 { 
  Name: 'AzureFirewallSubnet' }
  {
  Name:'ApplicationGatewaySubnet'               
  }
  { 
    Name: 'AzureBastionSubnet' }
]

var hubvnetnamevar = 'vnet-${envName}-aro-${regionsuffix}'
var bastionnsgName = 'nsg-AzureBastionSubnet'
var applicationGatewaySubnetnsgName = 'nsg-ApplicationGatewaySubnet'
var azurefirewallSubnetnsgName = 'nsg-AzureFirewallSubnet'
var routetableprefix = 'rt-snet-${envName}-aro-'
var privateEndpointSubnetName = 'snet-${envName}-aro-pep-${regionsuffix}'
var sharedServersSubnetName = 'snet-${envName}-aro-arosvs-${regionsuffix}'
var managementSubnetName = 'snet-${envName}-aro-mgmt-${regionsuffix}'
var gatewayroutetablename = 'rt-GatewaySubnet'
var applicationgatewayroutetablename = 'rt-ApplicationGatewaySubnet'
var privateendpointroutetablename = 'rt-snet-${envName}-aro-pep-${regionsuffix}'
var sharedserversroutetablename = 'rt-snet-${envName}-aro-arosvs-${regionsuffix}'
var sharedserversnsgname = 'nsg-snet-${envName}-aro-arosvs-${regionsuffix}'
var privateendpointnsgname = 'nsg-snet-${envName}-aro-pep-${regionsuffix}'
var managementroutetablename = 'rt-snet-${envName}-aro-mgmt-${regionsuffix}'
var managementnsgname = 'nsg-snet-${envName}-aro-mgmt-${regionsuffix}'
var diskaccessgroupvar = 'dag-${envName}-aro-${regionsuffix}'
var nsgNameprefix = 'nsg-snet-${envName}-aro-'

resource diskaccessgroup 'Microsoft.Compute/diskAccesses@2021-12-01' = {
  name: diskaccessgroupvar
  location: location
  tags: resourceTags
  properties: {
  }
}

resource bastionnsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: bastionnsgName
  location: location
  tags: resourceTags
  properties: {
    securityRules: [
      {
        name: 'Allow_HttpsInbound_IN'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_GatewayManager_IN'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_LoadBalancer_IN'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'BastionHostCommunication_IN'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'Explicit_Deny_All_Inbound_IN'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_RlpSsh_OUT'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'Allow_AzureCloud_OUT'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'BastionHostCommunication_OUT'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowGetSessionInformationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRanges: [
            '80'
          ]
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'Explicit_DenyAll_Outbound_OUT'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 200
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource azurefirewallSubnetnsg 'Microsoft.Network/networkSecurityGroups@2019-09-01' = {
  name: azurefirewallSubnetnsgName
  location: location
  tags: resourceTags
  properties: {
    securityRules: []
  }
}

resource applicationGatewaySubnetnsg 'Microsoft.Network/networkSecurityGroups@2019-09-01' = {
  name: applicationGatewaySubnetnsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow_Internet_OUT'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 140
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Allow_LoadBalancer_IN'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 140
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Allow_vNet_IN'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Allow_vNet_OUT'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Explicit_Deny_All_Inbound_IN'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 200
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Explicit_Deny_All_Inbound_OUT'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 200
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource nsgNameprefix_nsgName_Name_regionsuffix 'Microsoft.Network/networkSecurityGroups@2020-03-01' = [for item in nsgName: {
  name: '${nsgNameprefix}${toLower(item.Name)}-${regionsuffix}'
  location: location
  tags: resourceTags
  properties: {
    securityRules: []
  }
}]

resource rt_routetable 'Microsoft.Network/routeTables@2020-11-01' = [for item in routetable: {
  name: 'rt-${toLower(item.Name)}'
  location: location
  tags: resourceTags
  properties: {
    disableBgpRoutePropagation: false
    routes: []
  }
}]

resource routetableprefix_routetablecustom_Name_regionsuffix 'Microsoft.Network/routeTables@2020-11-01' = [for item in routetablecustom: {
  name: '${routetableprefix}${toLower(item.Name)}-${regionsuffix}'
  location: location
  tags: resourceTags
  properties: {
    disableBgpRoutePropagation: false
    routes: []
  }
}]

resource hub_vnet_name 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: hubvnetnamevar
  location: location
  tags: resourceTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${hub_vnet_address_prefix}.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '${hub_vnet_address_prefix}.0.192/26'
          networkSecurityGroup: {
            id: bastionnsg.id
          }
          serviceEndpoints: []
        }
      }
      {
        name: 'ApplicationGatewaySubnet'
        properties: {
          addressPrefix: '${hub_vnet_address_prefix}.0.128/26'
          networkSecurityGroup: {
            id: applicationGatewaySubnetnsg.id
          }
          routeTable: {
            id: resourceId('Microsoft.Network/routeTables', applicationgatewayroutetablename)
          }
          serviceEndpoints: []
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '${hub_vnet_address_prefix}.0.0/26'
          routeTable: {
            id: resourceId('Microsoft.Network/routeTables', gatewayroutetablename)
          }
          serviceEndpoints: []
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '${hub_vnet_address_prefix}.0.64/26'
          serviceEndpoints: []
        }
      }
      {
        name: privateEndpointSubnetName
        properties: {
          addressPrefix: '${hub_vnet_address_prefix}.1.0/26'
          routeTable: {
            id: resourceId('Microsoft.Network/routeTables', privateendpointroutetablename)
          }
          networkSecurityGroup: {
            id: resourceId('Microsoft.Network/networkSecurityGroups', privateendpointnsgname)
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
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
            {
              service: 'Microsoft.EventHub'
              locations: [
                location
              ]
            }
          ]
        }
      }
      {
        name: sharedServersSubnetName
        properties: {
          addressPrefix: '${hub_vnet_address_prefix}.1.64/26'
          routeTable: {
            id: resourceId('Microsoft.Network/routeTables', sharedserversroutetablename)
          }
          networkSecurityGroup: {
            id: resourceId('Microsoft.Network/networkSecurityGroups', sharedserversnsgname)
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
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
            {
              service: 'Microsoft.EventHub'
              locations: [
                location
              ]
            }
          ]
        }
      }
      {
        name: managementSubnetName
        properties: {
          addressPrefix: '${hub_vnet_address_prefix}.1.128/26'
          routeTable: {
            id: resourceId('Microsoft.Network/routeTables', managementroutetablename)
          }
          networkSecurityGroup: {
            id: resourceId('Microsoft.Network/networkSecurityGroups', managementnsgname)
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
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
            {
              service: 'Microsoft.EventHub'
              locations: [
                location
              ]
            }
          ]
        }
      }
    ]
  }
  dependsOn: [

    azurefirewallSubnetnsg
  ]
}

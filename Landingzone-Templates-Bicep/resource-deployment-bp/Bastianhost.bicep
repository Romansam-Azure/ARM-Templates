@description('Environment Name')
param envName string

@description('Pirmary Azure Region name in short')
param regionsuffix string

@description('Pirmary Azure Region name in short')
param region string

@description('Azure region for Bastion and virtual network')
param location string = resourceGroup().location

@metadata({ descriptoin: 'Hub Vnet Subscription ID' })
param hubsubscriptionID string

var publicipaddressnamevar = 'pip-bastion-${envName}-aro-prd-${regionsuffix}'
var bastion_subnet_name = 'AzureBastionSubnet'
var bastionnsgName = 'nsg-AzureBastionSubnet'
var hub_vnet_name = 'vnet-${envName}-aro-${regionsuffix}'
var hub_vnet_resource_group = 'rg-${envName}-aro-network-${region}'

resource public_ip_address_name 'Microsoft.Network/publicIpAddresses@2020-07-01' = {
  name: publicipaddressnamevar
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionnsg 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: bastionnsgName
  location: location
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

resource bast_rl_envname_aro_regionsuffix 'Microsoft.Network/bastionHosts@2020-07-01' = {
  name: 'bast-rl-${envName}-aro-${regionsuffix}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: resourceId(hubsubscriptionID, hub_vnet_resource_group, 'Microsoft.Network/virtualNetworks/subnets', hub_vnet_name, bastion_subnet_name)
          }
          publicIPAddress: {
            id: public_ip_address_name.id
          }
        }
      }
    ]
  }
}

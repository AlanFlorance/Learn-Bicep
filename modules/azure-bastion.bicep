// azure-bastion.bicep

@description('Azure VNet name')
param virtualNetworkName string = 'vnet01'

@description('Azure VNet IP Prefix CIDR')
param vNetIpPrefix string = '10.1.0.0/16'

@description('Azure Bastion Subnet IP Prefix')
param bastionSubnetIpPrefix string = '10.1.1.0/27'

@description('Azure Bastion host name')
param bastionHostName string

@description('Azure region to deploy all resources')
@allowed([
  'eastus'
  'eastus2'
  'westus'
  'westus2'
])
param location string

// Define the Azure Bastion resource
resource publicIp 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: '${bastionHostName}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Define the Azure VNet resource
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetIpPrefix
      ]
    }
  }
}

// Define the Azure Bastion Subnet
resource subNet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  parent: virtualNetwork
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: bastionSubnetIpPrefix
  }
}

// Define the Azure Bastion Host
resource bastionHost 'Microsoft.Network/bastionHosts@2020-06-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: subNet.id
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}

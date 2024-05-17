// Creates an Azure AI resource with proxied endpoints for the Azure AI services provider

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('AI hub name')
param aiHubName string

@description('AI hub display name')
param aiHubFriendlyName string = aiHubName

@description('AI hub description')
param aiHubDescription string

@description('Resource ID of the application insights resource for storing diagnostics logs')
param applicationInsightsId string

@description('Resource ID of the container registry resource for storing docker images')
param containerRegistryId string

@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string

@description('Resource ID of the storage account resource for storing experimentation outputs')
param storageAccountId string

@description('Resource ID of the AI Services resource')
param aiServicesId string

@description('Resource ID of the AI Services endpoint')
param aiServicesTarget string

@description('Resource name of the virtual network to deploy the resource into.')
param vnetName string

@description('Resource group name of the virtual network to deploy the resource into.')
param vnetRgName string

@description('Name of the subnet to deploy into.')
param subnetName string

@description('Unique Suffix used for name generation')
param uniqueSuffix string

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2023-10-01' = {
  name: aiHubName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // organization
    friendlyName: aiHubFriendlyName
    description: aiHubDescription

    // dependent resources
    keyVault: keyVaultId
    storageAccount: storageAccountId
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId

    // network settings
    publicNetworkAccess: 'Disabled'
    managedNetwork: {
      isolationMode: 'AllowOnlyApprovedOutbound'
      outboundRules: {}
    }

    // private link settings
    sharedPrivateLinkResources: []
  }
  kind: 'hub'

  resource aiServicesConnection 'connections@2024-01-01-preview' = {
    name: '${aiHubName}-connection-AzureOpenAI'
    properties: {
      category: 'AzureOpenAI'
      target: aiServicesTarget
      authType: 'ApiKey'
      isSharedToAll: true
      credentials: {
        key: '${listKeys(aiServicesId, '2021-10-01').key1}'
      }
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiServicesId
      }
    }
  }
}

var privateEndpointName = '${aiHubName}-AIHub-PE'
var targetSubResource = [
    'amlworkspace'
]
var vnetResourceId = '/subscriptions/${subscription().tenantId}/resourceGroups/${vnetRgName}/providers/Microsoft.Network/virtualNetworks/${vnetName}'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: vnetResourceId
    }
    customNetworkInterfaceName: '${aiHubName}-nic-${uniqueSuffix}'
    privateLinkServiceConnections: [
      {
        name: aiHubName
        properties: {
          privateLinkServiceId: aiHub.id
          groupIds: targetSubResource
        }
      }
    ]
  }

}

// module privateDnsDeployment './network/private-dns.bicep' = {
//   name: '${aiHubName}-DNS'
//   params: {}
//   dependsOn: [
//     privateEndpoint
//   ]
// }

// module virtualNetworkLink './network/virtual-network-link.bicep' = {
//   name: '${aiHubName}-VirtualNetworkLink'
//   params: {
//     virtualNetworkId: vnetId
//   }
//   dependsOn: [
//     privateDnsDeployment
//   ]
// }

// module dnsZoneGroup './network/dns-zone-group.bicep' = {
//   name: '${aiHubName}-dnsZoneGroup'
//   scope: resourceGroup()
//   params: {
//     vnetId: vnetId
//     privateEndpointName: privateEndpointName
//     location: location
//   }
//   dependsOn: [
//     privateEndpoint
//     privateDnsDeployment
//   ]
// }


output aiHubID string = aiHub.id

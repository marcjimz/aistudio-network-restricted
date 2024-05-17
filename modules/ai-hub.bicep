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

// @description('Resource ID of the virtual network')
// param vnetId string

// @description('Name of the subnet')
// param subnetName string

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
      isolationMode: 'Private'
      // whitelist additional outbound rules here, of types: 'FQDN' | 'PrivateEndpoint' | 'ServiceTag'
      // outboundRules: {
      //   type: 'FQDN'
      //   destinations: [
      //     'dc.services.visualstudio.com',
      //     'vortex.data.microsoft.com',
      //     'dc.applicationinsights.azure.com',
      //     'dc.services.visualstudio.com',
      //     'dc.applicationinsights.microsoft.com'
      //   ]
      // }
      outboundRules: {}
    }

    // private link settings
    sharedPrivateLinkResources: [
      {
        name: 'storageAccountLink'
        properties: {
          groupId: 'blob'
          privateLinkResourceId: 'storageAccountId'
          requestMessage: 'Please approve this private link.'
          status: 'Approved'
        }
      }
      // Add other private links as needed
    ]


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

output aiHubID string = aiHub.id

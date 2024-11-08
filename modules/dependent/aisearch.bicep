@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Name of the Azure Cognitive Search service')
param searchServiceName string

@description('Name of the private link endpoint for the search service')
param searchPrivateLinkName string

@description('Resource ID of the subnet')
param subnetId string

@description('Resource ID of the virtual network')
param virtualNetworkId string

@description('Search SKU')
@allowed([
  'basic'
  'standard'
  'standard2'
  'standard3'
  'storage_optimized_l1'
  'storage_optimized_l2'
])
param searchSkuName string = 'standard'

@description('Resource group name of the existing search service. Required if using an existing search service.')
param searchRgGroup string = ''

@description('Name of the existing search service. Required if using an existing search service.')
param searchResourceName string = ''

// Variable to determine whether to use an existing search service
var useExistingSearchService = !empty(searchRgGroup) && !empty(searchResourceName)

// Reference to the existing search service (if applicable)
resource existingSearchService 'Microsoft.Search/searchServices@2024-06-01-preview' existing = if (useExistingSearchService) {
  name: searchResourceName
  scope: resourceGroup(searchRgGroup)
}

// Definition for creating a new search service (only if not using existing)
resource newSearchService 'Microsoft.Search/searchServices@2024-06-01-preview' = if (!useExistingSearchService) {
  name: searchServiceName
  location: location
  tags: tags
  sku: {
    name: searchSkuName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    authOptions: { 
      aadOrApiKey: { 
        aadAuthFailureMode: 'http403'
      }
    }
    hostingMode: 'default'
    partitionCount: 1
    replicaCount: 1
    networkRuleSet: {
      ipRules: []
      bypass: 'AzureServices'
    }
    publicNetworkAccess: 'disabled'
  }
}

// Variable to reference the active search service (existing or new)
var searchServiceId = useExistingSearchService ? existingSearchService.id : newSearchService.id
var searchServicePrincipalId = useExistingSearchService ? existingSearchService.identity.principalId : newSearchService.identity.principalId
var searchServiceNameOutput = useExistingSearchService ? existingSearchService.name : newSearchService.name
var searchServiceEndpoint = 'https://${searchServiceNameOutput}.search.windows.net'

// Conditionally deploy private endpoint and DNS resources only when creating a new search service
resource searchPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = if (!useExistingSearchService) {
  name: searchPrivateLinkName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: searchPrivateLinkName
        properties: {
          groupIds: [
            'searchService'
          ]
          privateLinkServiceId: searchServiceId
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource searchPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (!useExistingSearchService) {
  name: 'privatelink.search.windows.net'
  location: 'global'
}

resource searchPrivateEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = if (!useExistingSearchService) {
  parent: searchPrivateEndpoint
  name: 'search-PrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.search.windows.net'
        properties: {
          privateDnsZoneId: searchPrivateDnsZone.id
        }
      }
    ]
  }
}

resource searchPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (!useExistingSearchService) {
  parent: searchPrivateDnsZone
  name: uniqueString(searchServiceId)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

// Outputs remain consistent regardless of using existing or new search service
output searchServiceId string = searchServiceId
output searchServicePrincipalId string = searchServicePrincipalId
output searchServiceName string = searchServiceNameOutput
output searchServiceEndpoint string = searchServiceEndpoint

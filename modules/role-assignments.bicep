@description('AI Services Name')
param aiServicesName string

@description('AI Services Id')
param aiServicesId string

@description('Search Service Name')
param searchServiceName string

@description('Search Service Id')
param searchServiceId string

@description('Storage Name')
param storageName string

var role = {
  SearchIndexDataContributor : '/providers/Microsoft.Authorization/roleDefinitions/7fba616c-7c6c-437e-b87b-b28c60ed4f65'
  SearchServiceContributor : '/providers/Microsoft.Authorization/roleDefinitions/f1815a41-1b1a-4865-879a-d756ff97164f'
  StorageBlobDataContributorAI : '/providers/Microsoft.Authorization/roleDefinitions/b7e6dc6d-fd28-4e4b-918d-b1d2eabf72a5' 
  CognitiveServicesOpenAiContributor : '/providers/Microsoft.Authorization/roleDefinitions/6062f2c7-5b0f-4d8b-b5ab-6c63e27a336f'
  StorageBlobDataContributorSearch : '/providers/Microsoft.Authorization/roleDefinitions/b7e6dc6d-fd28-4e4b-918d-b1d2eabf72a5'
}

resource searchService 'Microsoft.Search/searchServices@2023-11-01' existing = {
  name: searchServiceName
}

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiServicesName
}

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageName
}

resource searchIndexDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'SearchIndexDataContributor')
  scope: searchService
  properties: {
    roleDefinitionId: role.SearchIndexDataContributor
    principalId: aiServicesId
    principalType: 'ServicePrincipal'
  }
}

resource searchServiceContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'SearchServiceContributor')
  scope: searchService
  properties: {
    roleDefinitionId: role.SearchServiceContributor // Search Service Contributor
    principalId: aiServicesId
    principalType: 'ServicePrincipal'
  }
}

resource storageBlobDataContributorAI 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'StorageBlobDataContributorAI')
  scope: storage
  properties: {
    roleDefinitionId: role.StorageBlobDataContributorAI // Storage Blob Data Contributor
    principalId: aiServicesId
    principalType: 'ServicePrincipal'
  }
}

resource cognitiveServicesOpenAiContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'CognitiveServicesOpenAiContributor')
  scope: aiServices
  properties: {
    roleDefinitionId: role.CognitiveServicesOpenAiContributor
    principalId: searchServiceId
    principalType: 'ServicePrincipal'
  }
}

resource storageBlobDataContributorSearch 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'StorageBlobDataContributorSearch')
  scope: storage
  properties: {
    roleDefinitionId: role.StorageBlobDataContributorSearch
    principalId: searchServiceId
    principalType: 'ServicePrincipal'
  }
}

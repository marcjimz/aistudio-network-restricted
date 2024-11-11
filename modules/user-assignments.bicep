@description('AI Hub Name')
param aiHubName string

@description('AI Services Name')
param aiServicesName string

@description('Search Service Name')
param searchServiceName string

@description('Storage Name')
param storageName string

@description('Singular user principal id')
param user string

var roleId = {
  SearchIndexDataContributor : '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
  SearchServiceContributor : '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
  StorageAccountContributor : '17d1049b-9a84-46fb-8f53-869881c3d3ab'
  StorageBlobDataReader : '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
  StorageBlobDataContributor : 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' 
  CognitiveServicesContributor : '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'
  CognitiveServicesOpenAiContributor : 'a001fd3d-188f-4b5d-821b-7da978bf7442'
  StorageFileDataPrivilegedContributor : '69566ab7-960f-475b-8e7c-b3118f30c6bd'
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

resource searchServiceContributorUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchService.id, roleId.SearchServiceContributor, user)
  scope: searchService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId.SearchServiceContributor)
    principalId: user
  }
}

resource searchServiceIndexDataUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchService.id, roleId.SearchIndexDataContributor, user)
  scope: searchService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId.SearchIndexDataContributor)
    principalId: user
  }
}

resource cognitiveServicesOpenAiContributorUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aiServices.id, roleId.CognitiveServicesOpenAiContributor, user)
  scope: aiServices
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId.CognitiveServicesOpenAiContributor)
    principalId: user
  }
}

resource cognitiveServicesContributorUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aiServices.id, roleId.CognitiveServicesContributor, user)
  scope: aiServices
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId.CognitiveServicesContributor)
    principalId: user
  }
}

resource storageDataContributorUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storage.id, roleId.StorageBlobDataContributor, user)
  scope: storage
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId.StorageBlobDataContributor)
    principalId: user
  }
}

resource StorageFileDataPrivilegedContributorUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storage.id, roleId.StorageFileDataPrivilegedContributor, user)
  scope: storage
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId.StorageFileDataPrivilegedContributor)
    principalId: user
  }
}

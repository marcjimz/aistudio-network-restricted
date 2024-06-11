// Creates AI services resources, private endpoints, and DNS zones
@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Name of the AI service')
param aiServiceName string

@description('Name of the AI service private link endpoint for cognitive services')
param cognitiveServicesPleName string

@description('Name of the AI service private link endpoint for openai')
param openAiPleName string

@description('Resource ID of the subnet')
param subnetId string

@description('Resource ID of the virtual network')
param virtualNetworkId string

@allowed([
  'S0'
])

@description('AI service SKU')
param aiServiceSkuName string = 'S0'

var aiServiceNameCleaned = replace(aiServiceName, '-', '')

var cognitiveServicesPrivateDnsZoneName = 'privatelink.cognitiveservices.azure.com'
var openAiPrivateDnsZoneName = 'privatelink.openai.azure.com'

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: aiServiceNameCleaned
  location: location
  sku: {
    name: aiServiceSkuName
  }
  kind: 'AIServices'
  properties: {
    publicNetworkAccess: 'Enabled'
    apiProperties: {
      statisticsEnabled: false
    }
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: subnetId
          ignoreMissingVnetServiceEndpoint: false
        }
      ]
      ipRules: []
    }
    customSubDomainName: aiServiceNameCleaned
  }
}

resource cognitiveServicesPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: cognitiveServicesPleName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      { 
        name: cognitiveServicesPleName
        properties: {
          groupIds: [
            'account'
          ]
          privateLinkServiceId: aiServices.id
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

resource openAiPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: openAiPleName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: openAiPleName
        properties: {
            groupIds: [
            'openai'
            ]
          privateLinkServiceId: aiServices.id
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

resource cognitiveServicesPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: cognitiveServicesPrivateDnsZoneName
  location: 'global'
}

resource cognitiveServicesPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  parent: cognitiveServicesPrivateEndpoint
  name: 'blob-PrivateDnsZoneGroup'
  properties:{
    privateDnsZoneConfigs: [
      {
        name: cognitiveServicesPrivateDnsZoneName
        properties:{
          privateDnsZoneId: aiServices.id
        }
      }
    ]
  }
}

resource cognitiveServicesVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: cognitiveServicesPrivateDnsZone
  name: uniqueString(aiServices.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource openAiPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: openAiPrivateDnsZoneName
  location: 'global'
}

resource openAiPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  parent: openAiPrivateEndpoint
  name: 'flie-PrivateDnsZoneGroup'
  properties:{
    privateDnsZoneConfigs: [
      {
        name: openAiPrivateDnsZoneName
        properties:{
          privateDnsZoneId: openAiPrivateDnsZone.id
        }
      }
    ]
  }
}

resource openAiVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: openAiPrivateDnsZone
  name: uniqueString(aiServices.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}



output aiServicesId string = aiServices.id
output aiServicesEndpoint string = aiServices.properties.endpoint

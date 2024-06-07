// Creates AI services resources, private endpoints, and DNS zones
@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Name of the AI service')
param aiServiceName string

@description('Name of the AI service private link endpoint')
param aiServicePleName string

@description('Resource ID of the subnet')
param subnetId string

@description('Resource ID of the virtual network')
param virtualNetworkId string

@allowed([
  'F0'
  'S1'
  'S2'
  'S3'
])

@description('AI service SKU')
param aiServiceSkuName string = 'F0'

var aiServiceNameCleaned = replace(aiServiceName, '-', '')

var aiServicePrivateDnsZoneName = 'privatelink.cognitiveservices.azure.com'

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: aiServiceNameCleaned
  location: location
  sku: {
    name: aiServiceSkuName
  }
  kind: 'AIServices' // or 'OpenAI'
  properties: {
    publicNetworkAccess: 'Disabled'
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

resource aiServicePrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: aiServicePleName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      { 
        name: aiServicePleName
        properties: {
          groupIds: [
            'aiservice'
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

resource aiServicePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: aiServicePrivateDnsZoneName
  location: 'global'
}

resource aiServicePrivateEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: '${aiServicePrivateEndpoint.name}/aiservice-PrivateDnsZoneGroup'
  properties:{
    privateDnsZoneConfigs: [
      {
        name: aiServicePrivateDnsZoneName
        properties:{
          privateDnsZoneId: aiServicePrivateDnsZone.id
        }
      }
    ]
  }
}

resource aiServicePrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${aiServicePrivateDnsZone.name}/${uniqueString(aiServices.id)}'
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

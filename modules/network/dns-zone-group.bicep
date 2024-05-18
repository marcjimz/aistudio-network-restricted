@description('Name for the endpoint')
param privateEndpointName string

@description('Azure region of the deployment')
param location string

@description('Resource ID of the virtual network')
param vnetId string

var subscriptionId = subscription().subscriptionId
var vnetResourceGroup = resourceGroup(vnetId)

resource privateEndpointName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointName}/default'
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-api-azureml-ms'
        properties: {
            privateDnsZoneId: '/subscriptions/${subscriptionId}/resourceGroups/${vnetResourceGroup}/providers/Microsoft.Network/privateDnsZones/privatelink.api.azureml.ms'
        }
      }
      {
        name: 'privatelink-notebooks-azure-net'
        properties: {
            privateDnsZoneId: '/subscriptions/${subscriptionId}/resourceGroups/${vnetResourceGroup}/providers/Microsoft.Network/privateDnsZones/privatelink.notebooks.azure.net'
        }
      }
    ]
  }
}

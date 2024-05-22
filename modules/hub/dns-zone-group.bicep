@description('Name for the endpoint')
param privateEndpointName string

@description('Resource Vnet name of the virtual network')
param vnetRgName string

var subscriptionId = subscription().subscriptionId

resource privateEndpointName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointName}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-api-azureml-ms'
        properties: {
            privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', '/subscriptions/${subscriptionId}/resourceGroups/${vnetRgName}/providers/Microsoft.Network/privateDnsZones/privatelink.api.azureml.ms')
        }
      }
      {
        name: 'privatelink-notebooks-azure-net'
        properties: {
            privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', '/subscriptions/${subscriptionId}/resourceGroups/${vnetRgName}/providers/Microsoft.Network/privateDnsZones/privatelink.notebooks.azure.net')
        }
      }
    ]
  }
}

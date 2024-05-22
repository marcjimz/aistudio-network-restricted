@description('Name for the endpoint')
param privateEndpointName string

@description('Resource Vnet name of the virtual network')
param vnetRgName string

resource privateEndpointName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointName}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-api-azureml-ms'
        properties: {
            privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', '${vnetRgName}/privatelink.api.azureml.ms')
        }
      }
      {
        name: 'privatelink-notebooks-azure-net'
        properties: {
            privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', '${vnetRgName}/privatelink.notebooks.azure.net')
        }
      }
    ]
  }
}

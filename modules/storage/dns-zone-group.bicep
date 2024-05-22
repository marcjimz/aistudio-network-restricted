@description('Name for the blob PE endpoint')
param privateEndpointNameBlob string

@description('Name for the file PE endpoint')
param privateEndpointNameFile string

@description('Resource Vnet name of the virtual network')
param vnetRgName string

var subscriptionId = subscription().subscriptionId

resource privateEndpointName_blob_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: '${privateEndpointNameBlob}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
            privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', '/subscriptions/${subscriptionId}/resourceGroups/${vnetRgName}/providers/Microsoft.Network/privateDnsZones/privatelink.blob.${environment().suffixes.storage}')
        }
      }
    ]
  }
}

resource privateEndpointName_file_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: '${privateEndpointNameFile}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-file-core-windows-net'
        properties: {
            privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', '/subscriptions/${subscriptionId}/resourceGroups/${vnetRgName}/providers/Microsoft.Network/privateDnsZones/privatelink.file.${environment().suffixes.storage}')
        }
      }
    ]
  }
}

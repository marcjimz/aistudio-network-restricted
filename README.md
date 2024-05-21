---
description: This set of templates demonstrates how to set up Azure AI Studio with public internet access disabled and egress disabled, using Microsoft-managed keys for encryption and Microsoft-managed identity configuration for the AI resource.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: aistudio-network-restricted
languages:
- bicep
- json
---
# Azure AI Studio network-restricted setup 

<!-- ![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aistudio-basics/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aistudio-basics/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aistudio-basics/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aistudio-basicsd/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aistudio-basics/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aistudio-basicsd/CredScanResult.svg) -->

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aistudio-basics/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarcjimz%2Faistudio-network-restricted%2Ffeat%2Fvnet%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fmarcjimz%2Faistudio-network-restricted%2Ffeat%2Fvnet%2Fazuredeploy.json)

This set of templates demonstrates how to set up Azure AI Studio with a network-restricted configuration, meaning with public internet access disabled and egress disabled. It uses Microsoft-managed keys for encryption and Microsoft-managed identity configuration for the AI hub resource. Customization is required to create rules for the managed outbound access, and setup does not include additional rules to facilitate traffic access to the managed VNet. This template works as-is.

**NOTE: Azure AI Search and Azure AI Services do not support complete private deployments.**

Azure AI Studio is built on Azure Machine Learning as the primary resource provider and takes a dependency on the Cognitive Services (Azure AI Services) resource provider to surface model-as-a-service endpoints for Azure Speech, Azure Content Safety, and Azure OpenAI service.

An 'Azure AI hub' is a special kind of 'Azure Machine Learning workspace', that is kind = "hub".

![Architecture](https://learn.microsoft.com/en-us/azure/ai-studio/media/how-to/network/azure-ai-network-inbound.svg)

## Limitations

Limitations are maintained and kept up-to-date [here](https://learn.microsoft.com/en-us/azure/ai-studio/how-to/configure-private-link?source=recommendations&tabs=azure-portal#limitations):

* Private Azure AI Services and Azure AI Search aren't supported.
* The "Add your data" feature in the Azure AI Studio playground doesn't support private storage account.
* You might encounter problems trying to access the private endpoint for your hub if you're using Mozilla Firefox. This problem might be related to DNS over HTTPS in Mozilla Firefox. We recommend using Microsoft Edge or Google Chrome.

## Pre-requisites

This template expects that you have private VNet setup for your organization, and that you have traffic patterns established to access it securely. 

## Resources

| Provider and type | Description |
| - | - |
| `Microsoft.Resources/resourceGroups` | The resource group all resources get deployed into |
| `Microsoft.Insights/components` | An Azure Application Insights instance associated with the Azure Machine Learning workspace |
| `Microsoft.KeyVault/vaults` | An Azure Key Vault instance associated with the Azure Machine Learning workspace |
| `Microsoft.Storage/storageAccounts` | An Azure Storage instance associated with the Azure Machine Learning workspace |
| `Microsoft.ContainerRegistry/registries` | An Azure Container Registry instance associated with the Azure Machine Learning workspace |
| `Microsoft.MachineLearningServices/workspaces` | An Azure AI hub (Azure Machine Learning RP workspace of kind 'hub') |
| `Microsoft.CognitiveServices/accounts` | An Azure AI Services as the model-as-a-service endpoint provider (allowed kinds: 'AIServices' and 'OpenAI') |

## Learn more

If you are new to Azure AI Studio, see:

- [Azure AI Studio](https://aka.ms/aistudio/docs)
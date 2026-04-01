@description('Name of the Windows VM to monitor')
param vmName string

@description('Resource ID of the Data Collection Rule to associate')
param dcrId string

@description('Location of the VM')
param location string

// Reference the existing VM in this resource group
resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' existing = {
  name: vmName
}

// Deploy Azure Monitor Windows Agent extension (idempotent — no-op if already installed)
resource amaExtension 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  parent: vm
  name: 'AzureMonitorWindowsAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}

// Associate the Data Collection Rule with the VM
resource dcrAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: 'perf-rightsizing-dcr-association'
  scope: vm
  properties: {
    dataCollectionRuleId: dcrId
  }
}

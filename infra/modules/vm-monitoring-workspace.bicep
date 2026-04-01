@description('Location for all resources')
param location string

@description('Name for the Log Analytics Workspace')
param lawName string

// Log Analytics Workspace for VM performance data
resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: lawName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Data Collection Rule: collects Windows perf counters and sends to LAW
resource dcr 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: '${lawName}-perf-dcr'
  location: location
  properties: {
    destinations: {
      logAnalytics: [
        {
          name: 'lawDestination'
          workspaceResourceId: law.id
        }
      ]
    }
    dataSources: {
      performanceCounters: [
        {
          name: 'perfCounters60s'
          streams: [
            'Microsoft-Perf'
          ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            // CPU
            '\\Processor Information(_Total)\\% Processor Time'
            '\\Processor Information(_Total)\\% Privileged Time'
            '\\Processor Information(_Total)\\% User Time'
            '\\Processor Information(_Total)\\Processor Frequency'
            '\\System\\Processes'
            '\\System\\Processor Queue Length'
            // Memory
            '\\Memory\\Available MBytes'
            '\\Memory\\% Committed Bytes In Use'
            '\\Memory\\Committed Bytes'
            '\\Memory\\Cache Bytes'
            '\\Memory\\Pages/sec'
            // Disk
            '\\LogicalDisk(_Total)\\Disk Reads/sec'
            '\\LogicalDisk(_Total)\\Disk Writes/sec'
            '\\LogicalDisk(_Total)\\Disk Read Bytes/sec'
            '\\LogicalDisk(_Total)\\Disk Write Bytes/sec'
            '\\LogicalDisk(_Total)\\% Free Space'
            '\\LogicalDisk(_Total)\\Free Megabytes'
            '\\LogicalDisk(_Total)\\% Disk Time'
            '\\LogicalDisk(_Total)\\Avg. Disk sec/Read'
            '\\LogicalDisk(_Total)\\Avg. Disk sec/Write'
            // Network
            '\\Network Interface(*)\\Bytes Total/sec'
            '\\Network Interface(*)\\Bytes Received/sec'
            '\\Network Interface(*)\\Bytes Sent/sec'
            '\\Network Interface(*)\\Packets/sec'
          ]
        }
      ]
    }
    dataFlows: [
      {
        destinations: [
          'lawDestination'
        ]
        streams: [
          'Microsoft-Perf'
        ]
      }
    ]
  }
}

output lawId string = law.id
output lawName string = law.name
output dcrId string = dcr.id

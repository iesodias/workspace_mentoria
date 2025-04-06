@description('Nome da VM (máx. 15 caracteres)')
@minLength(3)
@maxLength(15)
param vmName string

@description('Região da Azure')
@allowed([
  'eastus'
  'westus'
  'brazilsouth'
])
param location string = 'eastus'

@description('Tamanho da VM')
@allowed([
  'Standard_B1s'
  'Standard_B2s'
  'Standard_D2s_v3'
])
param vmSize string = 'Standard_B1s'

@description('Usuário admin da VM')
param adminUsername string

@description('Senha do admin (mín. 12 caracteres, maiúsculas, números e símbolos)')
@secure()
@minLength(12)
param adminPassword string

// Imagem da VM (Ubuntu LTS)
var imageReference = {
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-jammy'
  sku: '22_04-lts'
  version: 'latest'
}

// Rede Virtual
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: '${vmName}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

// Public IP
resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: '${vmName}-pip'
  location: location
  sku: {  // MOVA A SKU PARA O NÍVEL SUPERIOR
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    // REMOVA A SKU DAQUI
  }
}

// Network Interface (NIC) com Public IP
resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

// VM
resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: 30
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// Outputs corrigidos:
@description('ID do IP Público da VM')
output publicIPId string = publicIP.id

@description('IP Privado da VM')
output vmPrivateIP string = nic.properties.ipConfigurations[0].properties.privateIPAddress

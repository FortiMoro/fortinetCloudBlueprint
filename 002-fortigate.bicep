/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                 //
//                                                                                                                                 //
//  This Template File should NOT be MODIFIED - Please make all modifications via "MAIN.BICEP"                                     //
//                                                                                                                                 //
//                                                                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                 //
//                                                          PARAMETERS                                                             //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

param adminUsername string
@secure()
param adminPassword string
param deploymentPrefix string
param fortiGateImageSKU string
param fortiGateImageVersion string
param fortiGateAdditionalCustomData string
param instanceType string
param availabilityOptions string 
param acceleratedNetworking bool
param publicIP1NewOrExisting string
param publicIP1Name string
param publicIP1ResourceGroup string
param publicIP2NewOrExisting string
param publicIP2Name string
param publicIP2ResourceGroup string
param publicIP3NewOrExisting string
param publicIP3Name string
param publicIP3ResourceGroup string
param vnetNewOrExisting string
param vnetName string
param vnetResourceGroup string
param vnetAddressPrefix string
param subnet1Name string
param subnet1Prefix string
param subnet1StartAddress string
param subnet2Name string
param subnet2Prefix string
param subnet2StartAddress string 
param subnet3Name string
param subnet3Prefix string
param subnet3StartAddress string 
param subnet4Name string
param subnet4Prefix string
param subnet4StartAddress string 
param fgtserialConsole string
param fortiManager string
param fortiManagerIP string 
param fortiManagerSerial string
param fortiGateLicenseBYOLA string 
param fortiGateLicenseBYOLB string 
param fortiGateLicenseFlexVMA string
param fortiGateLicenseFlexVMB string
param location string
param fortinetTags object 
param subnet7StartAddress string 

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                 //
//                                                          VARIABLES                                                              //
//                                                                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var imagePublisher = 'fortinet'
var imageOffer = 'fortinet_fortigate-vm_v5'
var var_availabilitySetName = '${deploymentPrefix}-FGT-AvailabilitySet'
var availabilitySetId = {
  id: availabilitySetName.id
}
var var_vnetName = ((vnetName == '') ? '${deploymentPrefix}-VNET' : vnetName)
var subnet1Id = ((vnetNewOrExisting == 'new') ? resourceId('Microsoft.Network/virtualNetworks/subnets', var_vnetName, subnet1Name) : resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', var_vnetName, subnet1Name))
var subnet2Id = ((vnetNewOrExisting == 'new') ? resourceId('Microsoft.Network/virtualNetworks/subnets', var_vnetName, subnet2Name) : resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', var_vnetName, subnet2Name))
var subnet3Id = ((vnetNewOrExisting == 'new') ? resourceId('Microsoft.Network/virtualNetworks/subnets', var_vnetName, subnet3Name) : resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', var_vnetName, subnet3Name))
var subnet4Id = ((vnetNewOrExisting == 'new') ? resourceId('Microsoft.Network/virtualNetworks/subnets', var_vnetName, subnet4Name) : resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', var_vnetName, subnet4Name))
var var_fgaVmName = '${deploymentPrefix}-FGT-A'
var var_fgbVmName = '${deploymentPrefix}-FGT-B'
var fmgCustomData = ((fortiManager == 'yes') ? '\nconfig system central-management\nset type fortimanager\n set fmg ${fortiManagerIP}\nset serial-number ${fortiManagerSerial}\nend\n config system interface\n edit port1\n append allowaccess fgfm\n end\n config system interface\n edit port2\n append allowaccess fgfm\n end\n' : '')
var fgaCustomDataFlexVM = ((fortiGateLicenseFlexVMA == '') ? '' : 'exec vm-license ${fortiGateLicenseFlexVMA}\n')
var fgBCustomDataFlexVM = ((fortiGateLicenseFlexVMB == '') ? '' : 'exec vm-license ${fortiGateLicenseFlexVMB}\n')
var customDataHeader = 'Content-Type: multipart/mixed; boundary="12345"\nMIME-Version: 1.0\n\n--12345\nContent-Type: text/plain; charset="us-ascii"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename="config"\n\n'
var fgaCustomDataBody = 'config system sdn-connector\nedit AzureSDN\nset type azure\nnext\nend\nconfig router static\n edit 1\n set gateway ${sn1GatewayIP}\n set device port1\n next\n edit 2\n set dst ${vnetAddressPrefix}\n set gateway ${sn2GatewayIP}\n set device port2\n next\n edit 3\nset dst 168.63.129.16 255.255.255.255\nset device port2\n set gateway ${sn2GatewayIP}\n next\nedit 4\nset dst 168.63.129.16 255.255.255.255\nset device port1\n set gateway ${sn1GatewayIP}\n next\n end\n config system probe-response\n set http-probe-value OK\n set mode http-probe\n end\n config system interface\n edit port1\n set mode static\n set ip ${sn1IPfga}/${sn1CIDRmask}\n set description external\n set allowaccess probe-response\n next\n edit port2\n set mode static\n set ip ${sn2IPfga}/${sn2CIDRmask}\n set description internal\n set allowaccess probe-response\n next\n edit port3\n set mode static\n set ip ${sn3IPfga}/${sn3CIDRmask}\n set description hasyncport\n next\n edit port4\n set mode static\n set ip ${sn4IPfga}/${sn4CIDRmask}\n set description management\n set allowaccess ping https ssh ftm\n next\n end\n config system ha\n set group-name AzureHA\n set mode a-p\n set hbdev port3 100\n set session-pickup enable\n set session-pickup-connectionless enable\n set ha-mgmt-status enable\n config ha-mgmt-interfaces\n edit 1\n set interface port4\n set gateway ${sn4GatewayIP}\n next\n end\n set override disable\n set priority 255\n set unicast-hb enable\n set unicast-hb-peerip ${sn3IPfgb}\n end\n${fortiGateVIPConfig}\n${fortiGateIPv4Policy}\n${fmgCustomData}${fortiGateAdditionalCustomData}\n${fgaCustomDataFlexVM}\n'
var fgbCustomDataBody = 'config system sdn-connector\nedit AzureSDN\nset type azure\nnext\nend\nconfig router static\n edit 1\n set gateway ${sn1GatewayIP}\n set device port1\n next\n edit 2\n set dst ${vnetAddressPrefix}\n set gateway ${sn2GatewayIP}\n set device port2\n next\n edit 3\nset dst 168.63.129.16 255.255.255.255\nset device port2\n set gateway ${sn2GatewayIP}\n next\nedit 4\nset dst 168.63.129.16 255.255.255.255\nset device port1\n set gateway ${sn1GatewayIP}\n next\n end\n config system probe-response\n set http-probe-value OK\n set mode http-probe\n end\n config system interface\n edit port1\n set mode static\n set ip ${sn1IPfgb}/${sn1CIDRmask}\n set description external\n set allowaccess probe-response\n next\n edit port2\n set mode static\n set ip ${sn2IPfgb}/${sn2CIDRmask}\n set description internal\n set allowaccess probe-response\n next\n edit port3\n set mode static\n set ip ${sn3IPfgb}/${sn3CIDRmask}\n set description hasyncport\n next\n edit port4\n set mode static\n set ip ${sn4IPfgb}/${sn4CIDRmask}\n set description management\n set allowaccess ping https ssh ftm\n next\n end\n config system ha\n set group-name AzureHA\n set mode a-p\n set hbdev port3 100\n set session-pickup enable\n set session-pickup-connectionless enable\n set ha-mgmt-status enable\n config ha-mgmt-interfaces\n edit 1\n set interface port4\n set gateway ${sn4GatewayIP}\n next\n end\n set override disable\n set priority 1\n set unicast-hb enable\n set unicast-hb-peerip ${sn3IPfga}\n end\n${fortiGateVIPConfig}\n${fortiGateIPv4Policy}\n${fmgCustomData}${fortiGateAdditionalCustomData}\n${fgBCustomDataFlexVM}\n'
var customDataLicenseHeader = '--12345\nContent-Type: text/plain; charset="us-ascii"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename="fgtlicense"\n\n'
var customDataFooter = '\n--12345--\n'
var fgaCustomDataCombined = '${customDataHeader}${fgaCustomDataBody}${customDataLicenseHeader}${fortiGateLicenseBYOLA}${customDataFooter}'
var fgbCustomDataCombined = '${customDataHeader}${fgbCustomDataBody}${customDataLicenseHeader}${fortiGateLicenseBYOLB}${customDataFooter}'
var fgaCustomData = base64(((fortiGateLicenseBYOLA == '') ? fgaCustomDataBody : fgaCustomDataCombined))
var fgbCustomData = base64(((fortiGateLicenseBYOLB == '') ? fgbCustomDataBody : fgbCustomDataCombined))
var fortiGateVIPConfig = '\nconfig firewall vip\nedit "Ubuntu-SSH-VIP"\nset extip ${publicIP1Name_resource.properties.ipAddress}\nset mappedip "${subnet7StartAddress}"\nset extintf "any"\nset portforward enable\nset extport 2222\nset mappedport 22\nnext\nend\n'
var fortiGateIPv4Policy = '''
config firewall policy
    edit 1
        set name "SSH_Inbound_Access"
        set srcintf "port1"
        set dstintf "port2"
        set action accept
        set srcaddr "all"
        set dstaddr "Ubuntu-SSH-VIP"
        set schedule "always"
        set service "SSH"
    next
    edit 2
        set name "Ubuntu_Outbound"
        set srcintf "port2"
        set dstintf "port1"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set nat enable
    next
end
'''
var var_fgaNic1Name = '${var_fgaVmName}-Nic1'
var fgaNic1Id = fgaNic1Name.id
var var_fgaNic2Name = '${var_fgaVmName}-Nic2'
var fgaNic2Id = fgaNic2Name.id
var var_fgbNic1Name = '${var_fgbVmName}-Nic1'
var fgbNic1Id = fgbNic1Name.id
var var_fgbNic2Name = '${var_fgbVmName}-Nic2'
var fgbNic2Id = fgbNic2Name.id
var var_fgaNic3Name = '${var_fgaVmName}-Nic3'
var fgaNic3Id = fgaNic3Name.id
var var_fgbNic3Name = '${var_fgbVmName}-Nic3'
var fgbNic3Id = fgbNic3Name.id
var var_fgaNic4Name = '${var_fgaVmName}-Nic4'
var fgaNic4Id = fgaNic4Name.id
var var_fgbNic4Name = '${var_fgbVmName}-Nic4'
var fgbNic4Id = fgbNic4Name.id
var var_serialConsoleStorageAccountName = 'fgtsc${uniqueString(resourceGroup().id)}'
var serialConsoleStorageAccountType = 'Standard_LRS'
var serialConsoleEnabled = ((fgtserialConsole == 'yes') ? true : false)
var var_publicIP1Name = ((publicIP1Name == '') ? '${deploymentPrefix}-FGT-PIP' : publicIP1Name)
var publicIP1Id = ((publicIP1NewOrExisting == 'new') ? publicIP1Name_resource.id : resourceId(publicIP1ResourceGroup, 'Microsoft.Network/publicIPAddresses', var_publicIP1Name))
var var_publicIP2Name = ((publicIP2Name == '') ? '${deploymentPrefix}-FGT-A-MGMT-PIP' : publicIP2Name)
var publicIP2Id = ((publicIP2NewOrExisting == 'new') ? publicIP2Name_resource.id : resourceId(publicIP2ResourceGroup, 'Microsoft.Network/publicIPAddresses', var_publicIP2Name))
var publicIPAddress2Id = {
  id: publicIP2Id
}
var var_publicIP3Name = ((publicIP3Name == '') ? '${deploymentPrefix}-FGT-B-MGMT-PIP' : publicIP3Name)
var publicIP3Id = ((publicIP3NewOrExisting == 'new') ? publicIP3Name_resource.id : resourceId(publicIP3ResourceGroup, 'Microsoft.Network/publicIPAddresses', var_publicIP3Name))
var publicIPAddress3Id = {
  id: publicIP3Id
}
var var_nsgName = '${deploymentPrefix}-NSG-Allow-All'
var nsgId = nsgName.id
var sn1IPArray = split(subnet1Prefix, '.')
var sn1IPArray2ndString = string(sn1IPArray[3])
var sn1IPArray2nd = split(sn1IPArray2ndString, '/')
var sn1CIDRmask = string(int(sn1IPArray2nd[1]))
var sn1IPArray3 = string((int(sn1IPArray2nd[0]) + 1))
var sn1IPArray2 = string(int(sn1IPArray[2]))
var sn1IPArray1 = string(int(sn1IPArray[1]))
var sn1IPArray0 = string(int(sn1IPArray[0]))
var sn1GatewayIP = '${sn1IPArray0}.${sn1IPArray1}.${sn1IPArray2}.${sn1IPArray3}'
var sn1IPStartAddress = split(subnet1StartAddress, '.')
var sn1IPfga = '${sn1IPArray0}.${sn1IPArray1}.${sn1IPArray2}.${int(sn1IPStartAddress[3])}'
var sn1IPfgb = '${sn1IPArray0}.${sn1IPArray1}.${sn1IPArray2}.${(int(sn1IPStartAddress[3]) + 1)}'
var sn2IPArray = split(subnet2Prefix, '.')
var sn2IPArray2ndString = string(sn2IPArray[3])
var sn2IPArray2nd = split(sn2IPArray2ndString, '/')
var sn2CIDRmask = string(int(sn2IPArray2nd[1]))
var sn2IPArray3 = string((int(sn2IPArray2nd[0]) + 1))
var sn2IPArray2 = string(int(sn2IPArray[2]))
var sn2IPArray1 = string(int(sn2IPArray[1]))
var sn2IPArray0 = string(int(sn2IPArray[0]))
var sn2GatewayIP = '${sn2IPArray0}.${sn2IPArray1}.${sn2IPArray2}.${sn2IPArray3}'
var sn2IPStartAddress = split(subnet2StartAddress, '.')
var sn2IPlb = '${sn2IPArray0}.${sn2IPArray1}.${sn2IPArray2}.${int(sn2IPStartAddress[3])}'
var sn2IPfga = '${sn2IPArray0}.${sn2IPArray1}.${sn2IPArray2}.${(int(sn2IPStartAddress[3]) + 1)}'
var sn2IPfgb = '${sn2IPArray0}.${sn2IPArray1}.${sn2IPArray2}.${(int(sn2IPStartAddress[3]) + 2)}'
var sn3IPArray = split(subnet3Prefix, '.')
var sn3IPArray2ndString = string(sn3IPArray[3])
var sn3IPArray2nd = split(sn3IPArray2ndString, '/')
var sn3CIDRmask = string(int(sn3IPArray2nd[1]))
var sn3IPArray2 = string(int(sn3IPArray[2]))
var sn3IPArray1 = string(int(sn3IPArray[1]))
var sn3IPArray0 = string(int(sn3IPArray[0]))
var sn3IPStartAddress = split(subnet3StartAddress, '.')
var sn3IPfga = '${sn3IPArray0}.${sn3IPArray1}.${sn3IPArray2}.${int(sn3IPStartAddress[3])}'
var sn3IPfgb = '${sn3IPArray0}.${sn3IPArray1}.${sn3IPArray2}.${(int(sn3IPStartAddress[3]) + 1)}'
var sn4IPArray = split(subnet4Prefix, '.')
var sn4IPArray2ndString = string(sn4IPArray[3])
var sn4IPArray2nd = split(sn4IPArray2ndString, '/')
var sn4CIDRmask = string(int(sn4IPArray2nd[1]))
var sn4IPArray3 = string((int(sn4IPArray2nd[0]) + 1))
var sn4IPArray2 = string(int(sn4IPArray[2]))
var sn4IPArray1 = string(int(sn4IPArray[1]))
var sn4IPArray0 = string(int(sn4IPArray[0]))
var sn4GatewayIP = '${sn4IPArray0}.${sn4IPArray1}.${sn4IPArray2}.${sn4IPArray3}'
var sn4IPStartAddress = split(subnet4StartAddress, '.')
var sn4IPfga = '${sn4IPArray0}.${sn4IPArray1}.${sn4IPArray2}.${int(sn4IPStartAddress[3])}'
var sn4IPfgb = '${sn4IPArray0}.${sn4IPArray1}.${sn4IPArray2}.${(int(sn4IPStartAddress[3]) + 1)}'
var var_internalLBName = '${deploymentPrefix}-FGT-ILB'
var internalLBFEName = '${deploymentPrefix}-ILB-${subnet2Name}-FrontEnd'
var internalLBFEId = resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', var_internalLBName, internalLBFEName)
var internalLBBEName = '${deploymentPrefix}-ILB-${subnet2Name}-BackEnd'
var internalLBBEId = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', var_internalLBName, internalLBBEName)
var internalLBProbeName = 'lbprobe'
var internalLBProbeId = resourceId('Microsoft.Network/loadBalancers/probes', var_internalLBName, internalLBProbeName)
var externalLBName_NatRule_FGAdminPerm_fga = '${var_fgaVmName}FGAdminPerm'
var externalLBId_NatRule_FGAdminPerm_fga = resourceId('Microsoft.Network/loadBalancers/inboundNatRules', var_externalLBName, externalLBName_NatRule_FGAdminPerm_fga)
var externalLBName_NatRule_SSH_fga = '${var_fgaVmName}SSH'
var externalLBId_NatRule_SSH_fga = resourceId('Microsoft.Network/loadBalancers/inboundNatRules', var_externalLBName, externalLBName_NatRule_SSH_fga)
var externalLBName_NatRule_FGAdminPerm_fgb = '${var_fgbVmName}FGAdminPerm'
var externalLBId_NatRule_FGAdminPerm_fgb = resourceId('Microsoft.Network/loadBalancers/inboundNatRules', var_externalLBName, externalLBName_NatRule_FGAdminPerm_fgb)
var externalLBName_NatRule_SSH_fgb = '${var_fgbVmName}SSH'
var externalLBId_NatRule_SSH_fgb = resourceId('Microsoft.Network/loadBalancers/inboundNatRules', var_externalLBName, externalLBName_NatRule_SSH_fgb)
var var_externalLBName = '${deploymentPrefix}-FGT-ELB'
var externalLBFEName = '${deploymentPrefix}-ELB-${subnet1Name}-FrontEnd'
var externalLBFEId = resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', var_externalLBName, externalLBFEName)
var externalLBBEName = '${deploymentPrefix}-ELB-${subnet1Name}-BackEnd'
var externalLBBEId = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', var_externalLBName, externalLBBEName)
var externalLBProbeName = 'lbprobe'
var externalLBProbeId = resourceId('Microsoft.Network/loadBalancers/probes', var_externalLBName, externalLBProbeName)
var useAZ = ((!empty(pickZones('Microsoft.Compute', 'virtualMachines', location))) && (availabilityOptions == 'Availability Zones'))
var zone1 = [
  '1'
]
var zone2 = [
  '2'
]

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                 //
//                                                          RESOURCES                                                              //
//                                                                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

resource serialConsoleStorageAccountName 'Microsoft.Storage/storageAccounts@2021-02-01' = if (fgtserialConsole == 'yes') {
  name: var_serialConsoleStorageAccountName
  location: location
  kind: 'Storage'
  sku: {
    name: serialConsoleStorageAccountType
  }
}

resource availabilitySetName 'Microsoft.Compute/availabilitySets@2021-07-01' = if (!useAZ) {
  name: var_availabilitySetName
  location: location
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 2
  }
  sku: {
    name: 'Aligned'
  }
}


resource internalLBName 'Microsoft.Network/loadBalancers@2020-04-01' = {
  name: var_internalLBName
  location: location
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: internalLBFEName
        properties: {
          privateIPAddress: sn2IPlb
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnet2Id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: internalLBBEName
      }
    ]
    loadBalancingRules: [
      {
        properties: {
          frontendIPConfiguration: {
            id: internalLBFEId
          }
          backendAddressPool: {
            id: internalLBBEId
          }
          probe: {
            id: internalLBProbeId
          }
          protocol: 'All'
          frontendPort: 0
          backendPort: 0
          enableFloatingIP: true
          idleTimeoutInMinutes: 5
        }
        name: 'lbruleFEall'
      }
    ]
    probes: [
      {
        properties: {
          protocol: 'Tcp'
          port: 8008
          intervalInSeconds: 5
          numberOfProbes: 2
        }
        name: 'lbprobe'
      }
    ]
  }
  dependsOn: [
  ]
}

resource nsgName 'Microsoft.Network/networkSecurityGroups@2020-04-01' = {
  name: var_nsgName
  location: location
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  properties: {
    securityRules: [
      {
        name: 'AllowAllInbound'
        properties: {
          description: 'Allow all in'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAllOutbound'
        properties: {
          description: 'Allow all out'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 105
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource publicIP1Name_resource 'Microsoft.Network/publicIPAddresses@2020-04-01' = if (publicIP1NewOrExisting == 'new') {
  name: var_publicIP1Name
  location: location
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: '${toLower(deploymentPrefix)}-${uniqueString(resourceGroup().id)}'
    }
  }
}

resource publicIP2Name_resource 'Microsoft.Network/publicIPAddresses@2020-04-01' = if (publicIP2NewOrExisting == 'new') {
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  name: var_publicIP2Name
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource publicIP3Name_resource 'Microsoft.Network/publicIPAddresses@2020-04-01' = if (publicIP3NewOrExisting == 'new') {
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  name: var_publicIP3Name
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource externalLBName 'Microsoft.Network/loadBalancers@2020-04-01' = {
  name: var_externalLBName
  location: location
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: externalLBFEName
        properties: {
          publicIPAddress: {
            id: publicIP1Id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: externalLBBEName
      }
    ]
    loadBalancingRules: [
      {
        properties: {
          frontendIPConfiguration: {
            id: externalLBFEId
          }
          backendAddressPool: {
            id: externalLBBEId
          }
          probe: {
            id: externalLBProbeId
          }
          protocol: 'Tcp'
          frontendPort: 22
          backendPort: 2222
          enableFloatingIP: true
          idleTimeoutInMinutes: 5
        }
        name: 'ExternalLBRule-FE-ssh'
      }
      {
        properties: {
          frontendIPConfiguration: {
            id: externalLBFEId
          }
          backendAddressPool: {
            id: externalLBBEId
          }
          probe: {
            id: externalLBProbeId
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: true
          idleTimeoutInMinutes: 5
        }
        name: 'ExternalLBRule-FE-http'
      }
      {
        properties: {
          frontendIPConfiguration: {
            id: externalLBFEId
          }
          backendAddressPool: {
            id: externalLBBEId
          }
          probe: {
            id: externalLBProbeId
          }
          protocol: 'Udp'
          frontendPort: 10551
          backendPort: 10551
          enableFloatingIP: true
          idleTimeoutInMinutes: 5
        }
        name: 'ExternalLBRule-FE-udp10551'
      }
    ]
    inboundNatRules: [
      {
        name: externalLBName_NatRule_SSH_fga
        properties: {
          frontendIPConfiguration: {
            id: externalLBFEId
          }
          protocol: 'Tcp'
          frontendPort: 50030
          backendPort: 22
          enableFloatingIP: false
        }
      }
      {
        name: externalLBName_NatRule_FGAdminPerm_fga
        properties: {
          frontendIPConfiguration: {
            id: externalLBFEId
          }
          protocol: 'Tcp'
          frontendPort: 40030
          backendPort: 443
          enableFloatingIP: false
        }
      }
      {
        name: externalLBName_NatRule_SSH_fgb
        properties: {
          frontendIPConfiguration: {
            id: externalLBFEId
          }
          protocol: 'Tcp'
          frontendPort: 50031
          backendPort: 22
          enableFloatingIP: false
        }
      }
      {
        name: externalLBName_NatRule_FGAdminPerm_fgb
        properties: {
          frontendIPConfiguration: {
            id: externalLBFEId
          }
          protocol: 'Tcp'
          frontendPort: 40031
          backendPort: 443
          enableFloatingIP: false
        }
      }
    ]
    probes: [
      {
        properties: {
          protocol: 'Tcp'
          port: 8008
          intervalInSeconds: 5
          numberOfProbes: 2
        }
        name: 'lbprobe'
      }
    ]
  }
}

resource fgaNic1Name 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  name: var_fgaNic1Name
  location: location
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: sn1IPfga
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnet1Id
          }
          loadBalancerBackendAddressPools: [
            {
              id: externalLBBEId
            }
          ]
          loadBalancerInboundNatRules: [
            {
              id: externalLBId_NatRule_SSH_fga
            }
            {
              id: externalLBId_NatRule_FGAdminPerm_fga
            }
          ]
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: acceleratedNetworking
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    externalLBName
  ]
}

resource fgbNic1Name 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  name: var_fgbNic1Name
  location: location
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: sn1IPfgb
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnet1Id
          }
          loadBalancerBackendAddressPools: [
            {
              id: externalLBBEId
            }
          ]
          loadBalancerInboundNatRules: [
            {
              id: externalLBId_NatRule_SSH_fgb
            }
            {
              id: externalLBId_NatRule_FGAdminPerm_fgb
            }
          ]
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: acceleratedNetworking
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    externalLBName
    fgaNic1Name
  ]
}

resource fgaNic2Name 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  name: var_fgaNic2Name
  location: location
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: sn2IPfga
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnet2Id
          }
          loadBalancerBackendAddressPools: [
            {
              id: internalLBBEId
            }
          ]
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: acceleratedNetworking
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    internalLBName
  ]
}

resource fgbNic2Name 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  name: var_fgbNic2Name
  location: location
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: sn2IPfgb
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnet2Id
          }
          loadBalancerBackendAddressPools: [
            {
              id: internalLBBEId
            }
          ]
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: acceleratedNetworking
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    internalLBName
    fgaNic2Name
  ]
}

resource fgaNic3Name 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  name: var_fgaNic3Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: sn3IPfga
          subnet: {
            id: subnet3Id
          }
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: acceleratedNetworking
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

resource fgbNic3Name 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  name: var_fgbNic3Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: sn3IPfgb
          subnet: {
            id: subnet3Id
          }
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: acceleratedNetworking
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

resource fgaNic4Name 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  name: var_fgaNic4Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: sn4IPfga
          publicIPAddress: ((publicIP2NewOrExisting != 'none') ? publicIPAddress2Id : null)
          subnet: {
            id: subnet4Id
          }
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: acceleratedNetworking
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

resource fgbNic4Name 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  name: var_fgbNic4Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: sn4IPfgb
          publicIPAddress: ((publicIP3NewOrExisting != 'none') ? publicIPAddress3Id : null)
          subnet: {
            id: subnet4Id
          }
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: acceleratedNetworking
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

resource fgaVmName 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: var_fgaVmName
  location: location
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  identity: {
    type: 'SystemAssigned'
  }
  zones: (useAZ ? zone1 : null)
  plan: {
    name: fortiGateImageSKU
    publisher: imagePublisher
    product: imageOffer
  }
  properties: {
    hardwareProfile: {
      vmSize: instanceType
    }
    availabilitySet: ((!useAZ) ? availabilitySetId : null)
    osProfile: {
      computerName: var_fgaVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      customData: fgaCustomData
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: fortiGateImageSKU
        version: fortiGateImageVersion
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          diskSizeGB: 30
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: fgaNic1Id
        }
        {
          properties: {
            primary: false
          }
          id: fgaNic2Id
        }
        {
          properties: {
            primary: false
          }
          id: fgaNic3Id
        }
        {
          properties: {
            primary: false
          }
          id: fgaNic4Id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: serialConsoleEnabled
        storageUri: ((fgtserialConsole == 'yes') ? reference(var_serialConsoleStorageAccountName, '2021-08-01').primaryEndpoints.blob : null)
      }
    }
  }
}

resource fgbVmName 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: var_fgbVmName
  location: location
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  identity: {
    type: 'SystemAssigned'
  }
  zones: (useAZ ? zone2 : null)
  plan: {
    name: fortiGateImageSKU
    publisher: imagePublisher
    product: imageOffer
  }
  properties: {
    hardwareProfile: {
      vmSize: instanceType
    }
    availabilitySet: ((!useAZ) ? availabilitySetId : null)
    osProfile: {
      computerName: var_fgbVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      customData: fgbCustomData
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: fortiGateImageSKU
        version: fortiGateImageVersion
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          diskSizeGB: 30
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: fgbNic1Id
        }
        {
          properties: {
            primary: false
          }
          id: fgbNic2Id
        }
        {
          properties: {
            primary: false
          }
          id: fgbNic3Id
        }
        {
          properties: {
            primary: false
          }
          id: fgbNic4Id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: serialConsoleEnabled
        storageUri: ((fgtserialConsole == 'yes') ? reference(var_serialConsoleStorageAccountName, '2021-08-01').primaryEndpoints.blob : null)
      }
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                 //
//                                                          OUTPUTS                                                                //
//                                                                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

output fortiGatePublicIP string = ((publicIP1NewOrExisting == 'new') ? reference(publicIP1Id).ipAddress : '')
output fortiGateFQDN string = ((publicIP1NewOrExisting == 'new') ? reference(publicIP1Id).dnsSettings.fqdn : '')
output fortiGateAManagementPublicIP string = ((publicIP2NewOrExisting == 'new') ? reference(publicIP2Id).ipAddress : '')
output fortiGateBManagementPublicIP string = ((publicIP3NewOrExisting == 'new') ? reference(publicIP3Id).ipAddress : '')
output externalLBFEName string = externalLBFEName



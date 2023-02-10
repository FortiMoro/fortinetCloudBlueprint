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
//                                                                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

param location string
param deploymentPrefix string
param vnetNewOrExisting string
param vnetName string
param vnetAddressPrefix string
param subnet1Name string
param subnet1Prefix string
param subnet2Name string
param subnet2Prefix string
param subnet2StartAddress string
param subnet3Name string
param subnet3Prefix string
param subnet4Name string
param subnet4Prefix string
param subnet5Name string
param subnet5Prefix string
param subnet6Name string
param subnet6Prefix string
param subnet7Name string
param subnet7Prefix string    
param fortinetTags object
param onPremRange string

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                 //
//                                                          VARIABLES                                                              // 
//                                                                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var var_vnet_Name = ((vnetName == '') ? '${deploymentPrefix}-VNET' : vnetName)
var routeTable7Name = '${deploymentPrefix}-RouteTable-${subnet7Name}'
var routeTable7Id = routeTable7.id
var routeTable5Name = '${deploymentPrefix}-RouteTable-${subnet5Name}'
var routeTable5Id = routeTable5.id
var sn2IPArray = split(subnet2Prefix, '.')
var sn2IPArray2 = string(int(sn2IPArray[2]))
var sn2IPArray1 = string(int(sn2IPArray[1]))
var sn2IPArray0 = string(int(sn2IPArray[0]))
var sn2IPStartAddress = split(subnet2StartAddress, '.')
var sn2IPlb = '${sn2IPArray0}.${sn2IPArray1}.${sn2IPArray2}.${int(sn2IPStartAddress[3])}'

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                 //
//                                                          RESOURCES                                                              // 
//                                                                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

resource routeTable7 'Microsoft.Network/routeTables@2020-04-01' = {
  name: routeTable7Name
  location: location
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  properties: {
    routes: [
      {
        name: 'toDefault'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: sn2IPlb
        }
      }
    ]
  }
}

resource routeTable5 'Microsoft.Network/routeTables@2020-04-01' = {
  name: routeTable5Name
  location: location
  tags: {
    provider: toUpper(fortinetTags.provider)
  }
  properties: {
    routes: [
      {
        name: 'toOnPrem'
        properties: {
          addressPrefix: onPremRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: sn2IPlb
        }
      }
    ]
  }
}

resource vnetName_resource 'Microsoft.Network/virtualNetworks@2020-04-01' = if (vnetNewOrExisting == 'new') {
    name: var_vnet_Name
    location: location
    properties: {
      addressSpace: {
        addressPrefixes: [
          vnetAddressPrefix
        ]
      }
      subnets: [
        {
          name: subnet1Name
          properties: {
            addressPrefix: subnet1Prefix
          }
        }
        {
          name: subnet2Name
          properties: {
            addressPrefix: subnet2Prefix
          }
        }
        {
          name: subnet3Name
          properties: {
            addressPrefix: subnet3Prefix
            routeTable: {
              id: routeTable5Id
            }
          }
        }
        {
          name: subnet4Name
          properties: {
            addressPrefix: subnet4Prefix
          }
        }
        {
          name: subnet5Name
          properties: {
            addressPrefix: subnet5Prefix
          }
        }
        {
          name: subnet6Name
          properties: {
            addressPrefix: subnet6Prefix
          }
        }
        {
          name: subnet7Name
          properties: {
            addressPrefix: subnet7Prefix
            routeTable: {
              id: routeTable7Id
            }
          }
        }
      ]
    }
  }



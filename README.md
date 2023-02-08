# Fortinet Reference Architecture for Azure

## Prologue

The purpose of this architecture is to provide the user with a set of templates that will deploy and preconfigure perimeter solution that addresses the dynamic needs of an environment, while optimizing for security. The templates are equipped with a FortiGate Next Generation Firewall, FortiWeb WAF and DVWA Endpoint. While the WAF is designed to secure your Web Servers against inbound attacks over HTTP/HTTPs, the Next Generation Firewall is a General Purpose tool that will enable your connectivity (IPSec, SSL VPN, SDWAN) in addition to offering Multi-Protocol security and being your primary egress mechanism.

![fgfwb](https://raw.githubusercontent.com/AJLab-GH/fortinetCloudBlueprint/staging/Images/fgfwb.png)


The FortiGate and FortiWeb in this solution compliment one-another. The FortiWeb has advanced features that the FortiGate does not, but can only apply those protections to HTTP, HTTPs. The FortiGate can support a variety of protocols, perform dynamic routing, terminate VPN, perform SD-WAN and so much more.

![DesignConsiderations](https://raw.githubusercontent.com/AJLab-GH/fortinetCloudBlueprint/staging/Images/designconsiderations.png)

## Introduction

More and more enterprises are turning to Microsoft Azure to extend or replace internal data centers and take advantage of the elasticity of the public cloud. While Azure secures the infrastructure, you are responsible for protecting the resources you put in it. As workloads are being moved from local data centers, connectivity and security are key elements to take into account. This modularized deployment deploys and preconfigures Fortinet's FortiGate (NGFW), and Fortinet's FortiWeb (Web Application Firewall) to facilitate your Proof of Concept (PoC) journey and to ensure the utmost security posture for your Azure environment.

[FortiGate-VM](https://www.fortinet.com/products/private-cloud-security/fortigate-virtual-appliances) offers a consistent security posture and protects multi-protocol connectivity across public and private clouds, while high-speed VPN connections protect data.

[FortiWeb-VM](https://www.fortinet.com/products/web-application-firewall/fortiweb) protects business-critical web applications from attacks that target known and unknown vulnerabilities. Advanced ML-powered features improve security and reduce administrative overhead.

This set of Bicep templates deploys:

 an Active/Passive FortiGate (NGFW) pair combined with the Microsoft Azure Standard Load Balancer both on the external and the internal side. Additionally, Fortinet Fabric Connectors deliver the ability to create dynamic security policies. This FortiGate cluster will be responsible for multi-protocol inspection, IPSec connectivity and Internet Egress.

 an Active/Active FortiWeb (WAF) pair operating in Reverse Proxy combined with the Microsoft Azure Standard Load Balancer on the external side. This FortiWeb cluster will be responsible protecting traffic inbound to your Web Applications, i.e HTTP(s) only.

 a Damn Vulnerable Web Application (DVWA). Damn Vulnerable Web Application (DVWA) is a PHP/MySQL web application that is damn vulnerable. Its main goal is to be an aid for security professionals to test their skills and tools in a legal environment, help web developers better understand the processes of securing web applications and to aid both students & teachers to learn about web application security in a controlled class room environment.

## Design

This FortiGate setup will receive non-http(s) traffic using user defined routing (UDR) and public IPs. You can send all or specific traffic that needs inspection, going to/coming from on-prem networks or public internet by adapting the UDR routing. Here is an example of [Internet originating Non-HTTP(S) flows (i.e SSH etc)](doc/InternetNonHTTP.md)

This FortiWeb setup will only receive http(s) traffic using user defined routing (UDR) and public IPs. You can send all or specific http(s) traffic that needs inspection, going to/coming from on-prem networks or public internet by adapting the UDR routing. Here is an example of [Internet originating HTTP(S) flows ](doc/InternetHTTP.md)

This Azure BICEP template will automatically deploy a full working environment containing the the following components.

- 2 FortiGate Firewalls in an active/passive deployment
- 2 FortiWeb WAFs in an active/active deployment
- 2 Public Azure Standard Load Balancer for communication with internet (1x per cluster)
- 2 internal Azure Standard Load Balancer to receive all internal traffic and forwarding towards Azure Gateways connecting ExpressRoute or Azure VPNs.
- 1 VNET with 1 protected subnets
- 4 public IP for services and FortiGate/FortiWeb management
- User Defined Routes (UDR) to ensure full end-to-end communication via the FortiGate/FortiWeb deployment

![Detailed View](https://raw.githubusercontent.com/AJLab-GH/fortinetCloudBlueprint/staging/Images/Detailed%20View.png)

To enhance the availability of the solution VM can be installed in different Availability Zones instead of an Availability Set. If Availability Zones deployment is selected but the location does not support Availability Zones an Availability Set will be deployed. If Availability Zones deployment is selected and Availability Zones are available in the location, FortiGate A will be placed in Zone 1, FortiGate B will be placed in Zone 2.

These templates can also be used to extend or customized based on your requirements. Additional subnets besides the one's mentioned above are not automatically generated. By adapting the templates you can add additional subnets which prefereably require their own routing tables.

## How to deploy

The solution can be deployed using the Azure Portal or Azure CLI. There are 3 variables needed to complete kickstart the deployment. The BICEP deployment will ask them automatically via AZ CLI. When you deploy the ARM template the Azure Portal will request the variables as a requirement.

- PREFIX : This prefix will be added to each of the created resources for easy of use, manageability and visibility.
- USERNAME : The username used to login to the FortiGate GUI and SSH mangement UI.
- PASSWORD : The password used for the FortiGate GUI and SSH management UI.

## Making modifications to the template

If you do not wish to use the OOTB values for your deployment, changes can be made to the "000-main.bicep" file. This file is the ONLY file where values can be changed or modified. Changes to the modules will be inherited from the Main File.

### Azure Portal

Azure Portal Wizard:
[![Deploy Azure Portal Button](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F40net-cloud%2Ffortinet-azure-solutions%2Fmain%2FFortiGate%2FActive-Active-ELB-ILB%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2F40net-cloud%2Ffortinet-azure-solutions%2Fmain%2FFortiGate%2FActive-Active-ELB-ILB%2FcreateUiDefinition.json)

Custom deployment:
[![Deploy Azure Portal Button](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F40net-cloud%2Ffortinet-azure-solutions%2Fmain%2FFortiGate%2FActive-Active-ELB-ILB%2Fazuredeploy.json)


### Azure CLI

To deploy via Azure Cloud Shell you can connect via the Azure Portal or directly to [https://shell.azure.com/](https://shell.azure.com/).

- Login into the Azure Cloud Shell
- Run the following commands in the Azure Cloud:

git https://github.com/AJLab-GH/fortinetCloudBlueprint.git

Create a resource group for your deployment

- az group create --location (location) --name (resourceGroupName)

![Create Resource Group](https://raw.githubusercontent.com/AJLab-GH/fortinetCloudBlueprint/staging/Images/createRG.png)

Deploy the templates

- az deployment group create --name (deploymentName) --resource-group (resourceGroupName) --template-file 000-main.bicep

The script will ask you a few questions to bootstrap a full deployment.

![Input Variables](https://raw.githubusercontent.com/AJLab-GH/fortinetCloudBlueprint/staging/Images/ProvideValue.png)

After deployment you can output the important values such as public IP addresses, etc that you'll need to connect to your deployment.

- az deployment group show  -g (resourceGroupName)   -n (deploymentName)  --query properties.outputs

![Input Variables](https://raw.githubusercontent.com/AJLab-GH/fortinetCloudBlueprint/staging/Images/Outputs.png)

## Requirements and limitations

The Bicep template deploys different resources and it is required to have the access rights and quota in your Microsoft Azure subscription to deploy the resources.

- The template will deploy Standard Fs VMs for this architecture. Other VM instances are supported as well with a minimum of 4 NICs for the FortiGate deployment and 2 NICs for the FortiWeb deployment. A list can be found [here](https://docs.fortinet.com/document/fortigate/6.4.0/azure-cookbook/562841/instance-type-support)

- Licenses for Fortigate/FortiWeb
  - BYOL: A demo license can be made available via your Fortinet partner or on our website. These can be injected during deployment or added after deployment. Purchased licenses need to be registered on the [Fortinet support site](http://support.fortinet.com). Download the .lic file after registration. Note, these files may not work until 60 minutes after it's initial creation.
  - PAYG or OnDemand: These licenses are automatically generated during the deployment of the FortiGate systems.

- The password provided during deployment must need password complexity rules from Microsoft Azure:
  - It must be 12 characters or longer
  - It needs to contain characters from at least 3 of the following groups: uppercase characters, lowercase characters, numbers, and special characters excluding '\' or '-'

- The terms for the PAYG or BYOL images in the Azure Marketplace needs to be accepted once before usage. This is done automatically during deployment via the Azure Portal. For the Azure CLI the commands below need to be run before the first deployment in a subscription.
  - BYOL FortiGate
`az vm image terms accept --publisher fortinet --offer fortinet_fortigate-vm_v5 --plan fortinet_fg-vm`
  - BYOL FortiWeb
`az vm image terms accept --publisher fortinet --offer fortinet_fortiweb-vm_v5 --plan fortinet_fw-vm`
  - PAYG FortiGate
`az vm image terms accept --publisher fortinet --offer fortinet_fortigate-vm_v5 --plan fortinet_fg-vm_payg_2022`
  - PAYG FortiWeb
`az vm image terms accept --publisher fortinet --offer fortinet_fortiweb-vm_v5 --plan fortinet_fw-vm_payg_v2`

## Fabric Connector

The FortiGate-VM uses [Managed Identities](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/) for the SDN Fabric Connector. A SDN Fabric Connector is created automatically during deployment. After deployment, it is required apply the 'Reader' role to the Azure Subscription you want to resolve Azure Resources from. More information can be found on the [Fortinet Documentation Libary](https://docs.fortinet.com/vm/azure/fortigate/7.0/azure-administration-guide/7.0.0/236610/creating-a-fabric-connector-using-a-managed-identity).
## Support

Fortinet-provided scripts in this and other GitHub projects do not fall under the regular Fortinet technical support scope and are not supported by FortiCare Support Services.
For direct issues, please refer to the [Issues](https://github.com/40net-cloud/fortinet-azure-solutions/issues) tab of this GitHub project.

## License

[License](LICENSE) © Fortinet Technologies. All rights reserved.
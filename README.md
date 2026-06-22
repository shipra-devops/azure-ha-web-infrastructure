# Azure Highly Available Web Infrastructure (Terraform)

![Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?style=flat&logo=microsoft-azure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![IaC](https://img.shields.io/badge/Infrastructure_as_Code-Terraform-blueviolet?style=flat)

A production-ready, Infrastructure as Code (IaC) project that provisions a **Highly Available web infrastructure on Microsoft Azure** using Terraform. This project demonstrates core cloud administration skills including networking, virtual machines, security groups, and load balancing — all automated and repeatable.

---

## Architecture Overview

```
Internet
    |
    └── Load Balancer (optional)
            |
    ┌───────┴────────┐
    |                |
  VM-1             VM-2        ← Multiple VMs across availability zones
    |                |
    └────────┬───────┘
             |
      Network Security Group (NSG)
             |
      Azure Virtual Network (VNet)
      10.0.0.0/16
             |
        Subnet(s)
```

---

## Features

- **High Availability** — multiple virtual machines provisioned for redundancy
- **Azure Virtual Network (VNet)** — isolated, secure network environment
- **Subnets** — logical network segmentation
- **Network Security Groups (NSG)** — firewall rules controlling inbound/outbound traffic
- **Optional Load Balancer** — distributes traffic evenly across VMs
- **Infrastructure as Code** — entire infrastructure defined in Terraform, fully repeatable and version-controlled
- **Linux Virtual Machines** — Ubuntu-based VMs ready for web workloads

---

## Technologies Used

| Technology | Purpose |
|---|---|
| Terraform | Infrastructure provisioning and state management |
| Microsoft Azure | Cloud platform |
| Azure VNet + Subnets | Network isolation and segmentation |
| Network Security Groups | Firewall and traffic control |
| Linux (Ubuntu) VMs | Compute layer for web workloads |
| Azure Load Balancer | Optional traffic distribution |

---

## Prerequisites

Before you begin, ensure you have the following installed and configured:

- [Terraform](https://developer.hashicorp.com/terraform/install) (v1.0+)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- An active [Azure subscription](https://azure.microsoft.com/en-us/free/)
- Azure CLI authenticated:

```bash
az login
az account set --subscription "<your-subscription-id>"
```

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/shipra-devops/azure-ha-web-infrastructure.git
cd azure-ha-web-infrastructure
```

### 2. Initialise Terraform

```bash
terraform init
```

### 3. Review the execution plan

```bash
terraform plan
```

### 4. Deploy the infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm. Terraform will provision all resources in your Azure subscription.

### 5. Destroy resources when done

```bash
terraform destroy
```

> **Cost tip:** Always run `terraform destroy` when finished to avoid ongoing Azure charges.

---

## Project Structure

```
azure-ha-web-infrastructure/
├── main.tf           # Core resource definitions
├── variables.tf      # Input variables
├── outputs.tf        # Output values (IPs, resource names)
├── providers.tf      # Azure provider configuration
└── README.md         # Project documentation
```

---

## Key Azure Resources Provisioned

- `azurerm_resource_group` — container for all project resources
- `azurerm_virtual_network` — VNet with defined address space
- `azurerm_subnet` — subnet(s) within the VNet
- `azurerm_network_security_group` — NSG with inbound/outbound rules
- `azurerm_linux_virtual_machine` — Ubuntu VMs (multiple for HA)
- `azurerm_lb` *(optional)* — Azure Load Balancer

---

## What I Learned

This project strengthened my understanding of:

- Designing **highly available** cloud architectures on Azure
- Writing and structuring **Terraform modules** for real-world infrastructure
- Configuring **VNets, subnets, and NSG rules** for secure networking
- Deploying and managing **Linux VMs** at scale using IaC
- The importance of **state management** with `terraform.tfstate`

---

## Portfolio Context

This project was built as part of my Azure Cloud Administration learning journey. It maps directly to the following **AZ-104: Microsoft Azure Administrator** exam domains:

- Manage Azure identities and governance
- Implement and manage virtual networking
- Deploy and manage Azure compute resources

---

## Author

**Shipra** — Cloud Administrator in training | [GitHub](https://github.com/shipra-devops)



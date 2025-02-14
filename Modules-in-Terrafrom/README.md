Terraform modules are a key feature in Terraform that allow for organizing and reusing infrastructure code across multiple projects or environments. Here's an overview:

### What is a Terraform Module?
A **module** in Terraform is a container for multiple resources that are used together. Modules consist of:
- **Input variables:** Parameters to customize the module’s behavior.
- **Resources:** The infrastructure components (e.g., EC2 instances, VPCs, etc.).
- **Output values:** Data to pass back to the caller or other modules.

### Benefits of Terraform Modules
1. **Reusability:** Modules allow you to define infrastructure components once and reuse them in multiple projects.
2. **Maintainability:** Organizing resources in modules can make large configurations easier to manage and update.
3. **Encapsulation:** By using modules, you can hide complexity and expose only necessary configuration details.
4. **Consistency:** Using the same modules across environments (e.g., staging, production) ensures that infrastructure remains consistent.

### Types of Modules
1. **Root Module:** Every Terraform configuration has at least one module, known as the root module. It includes the `.tf` files in the working directory.
2. **Child Module:** When a module calls another module, the called module is a child module. Child modules can be located locally or remotely.

### Using a Module
To use a module in a Terraform configuration, you specify a `module` block:

```hcl
module "vpc" {
  source = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  # other input variables
}
```

The `source` attribute tells Terraform where the module is located. This can be a local path, a Git repository, or the Terraform Module Registry.

### Module Composition
Modules are often composed to manage complex infrastructure. For example, you might create:
- A **network module** for setting up VPCs, subnets, and security groups.
- An **instance module** for deploying EC2 instances or other compute resources.

### Best Practices for Terraform Modules
1. **Keep modules small and focused**: Avoid overloading a module with too many responsibilities.
2. **Version control**: If using remote modules, pin versions to ensure reproducibility.
3. **Use naming conventions**: For easier management and identification.
4. **Document modules**: Make use of README files to document module inputs, outputs, and purpose.

 VPC infrastructure project using Terraform. Here's a step-by-step guide on how you can organize it:

Project Structure
A typical Terraform project is divided into multiple files and directories to keep the code organized. For a VPC infrastructure, you can structure your project like this:

```bash

/terraform-vpc-project
  ├── /modules
  │   └── /vpc
  │       ├── main.tf
  │       ├── variables.tf
  │       ├── outputs.tf
  │       └── README.md
  ├── /environments
  │   ├── /dev
  │   │   └── main.tf
  │   └── /prod
  │       └── main.tf
  ├── main.tf
  ├── variables.tf
  ├── outputs.tf
  └── terraform.tfvars
```

Step-by-Step Breakdown:
Root Directory (/terraform-vpc-project)

This is where the top-level configuration lives. It’s responsible for calling the VPC module and providing values to input variables.
Modules Directory (/modules/vpc)

This is where the actual VPC resources are defined. By keeping the VPC configuration inside a module, you can easily reuse it for different environments (e.g., dev, prod).

main.tf: Define the core AWS resources for your VPC, such as:

VPC
Subnets (public/private)
Route tables
Internet gateway
NAT gateway
Security groups



### VPC Infrastructure

We’ll keep variables inside the `variables.tf` file and define their values directly in the **`main.tf`** file when calling the module. This way, everything stays clear and in one place.

---

### 1. **Main Terraform Configuration**
This file will create the VPC, subnets, Internet Gateway, NAT Gateway, and route tables, all in one place.

```hcl
# main.tf

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source             = "../terraform-modules/vpc"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  vpc_name           = "development-vpc"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
```

### 2. **VPC Module**
Inside your `terraform-modules/vpc/` directory, you’ll set up the resources like VPC, subnets, route tables, etc.

#### **VPC Module - `main.tf`**
This is where we define the VPC and related resources.

```hcl
# terraform-modules/vpc/main.tf

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${count.index}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Private Subnet ${count.index}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.vpc_name}-nat"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-public-route"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-private-route"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
```

#### **VPC Module - `variables.tf`**
In this file, you’ll define the variables used by the module to configure the VPC, subnets, etc.

```hcl
# terraform-modules/vpc/variables.tf

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}
```

#### **VPC Module - `outputs.tf`**
Finally, output the resources you want to reference later, such as VPC and subnet IDs.

```hcl
# terraform-modules/vpc/outputs.tf

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
```

---

### How to Apply:

1. **Run Initialization**:
   Open your terminal in the `Development_Infrastructure` directory and initialize Terraform.

   ```bash
   terraform init
   ```

2. **Validate Configuration**:
   Check if everything is correctly set up:

   ```bash
   terraform validate
   ```

3. **Apply the Changes**:
   Once everything is validated, apply the configuration to create your infrastructure.

   ```bash
   terraform apply
   ```

4. **Review the Output**:
   The `vpc_id` and subnet IDs will be output to the console once the resources are created.

---


### HCL (HashiCorp Configuration Language)

**HashiCorp Configuration Language (HCL)** is the language used by Terraform for defining infrastructure as code. HCL is designed to be both human-readable and machine-friendly, making it easy to define infrastructure resources and configurations for cloud providers.

### Key Features of HCL:

- **Declarative**: You define *what* you want rather than *how* to achieve it. Terraform figures out the steps to reach the desired state.
- **Human-Readable Syntax**: HCL is easy to write and understand, using key-value pairs, blocks, and expressions.
- **Supports Variables and Outputs**: It allows using variables for dynamic configurations and outputs for fetching values after resource creation.

### Basic Structure of HCL:

HCL files typically have a `.tf` extension, and they consist of resources, variables, providers, and outputs.

#### Example HCL Syntax for Terraform:

```hcl
# Define a provider (e.g., AWS)
provider "aws" {
  region = "us-west-2"
}

# Define a resource (e.g., EC2 instance)
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  tags = {
    Name = "MyInstance"
  }
}

# Define output to display the public IP of the instance
output "instance_ip" {
  value = aws_instance.example.public_ip
}
```

### Key Elements of HCL:

1. **Providers**: Define the cloud provider or other services you are interacting with.
   ```hcl
   provider "aws" {
     region = "us-east-1"
   }
   ```

2. **Resources**: Represent cloud services or infrastructure components (like EC2 instances, S3 buckets, etc.).
   ```hcl
   resource "aws_s3_bucket" "my_bucket" {
     bucket = "my-unique-bucket-name"
     acl    = "private"
   }
   ```

3. **Variables**: Parameters that can be passed into the configuration to make it more dynamic.
   ```hcl
   variable "instance_type" {
     description = "The type of instance to use"
     default     = "t2.micro"
   }
   ```

4. **Outputs**: Values to be displayed after the infrastructure is applied, such as IP addresses or instance IDs.
   ```hcl
   output "instance_ip" {
     value = aws_instance.example.public_ip
   }
   ```

5. **Modules**: A way to organize and reuse code across different projects by grouping related resources together.
   ```hcl
   module "vpc" {
     source = "terraform-aws-modules/vpc/aws"
     version = "3.0.0"

     name = "my-vpc"
     cidr = "10.0.0.0/16"
   }
   ```

### Example Project Structure:

```bash
.
├── main.tf         # Main configuration file
├── variables.tf    # Variable definitions
├── outputs.tf      # Outputs
└── terraform.tfvars # Values for the variables
```

### Benefits of HCL:
- **Easy to learn**: HCL is simple and uses an intuitive syntax, making it easy for users to understand and write configuration files.
- **Readable**: The declarative syntax makes it clear what resources and configurations are being set up.
- **Modular**: You can create reusable modules to avoid repetitive configurations.

HCL is the core language for defining infrastructure with Terraform, and understanding its structure will make building and managing cloud resources more efficient.

In Terraform, configuration files are written using **HCL (HashiCorp Configuration Language)**, and the structure is organized into different **block types**. Each block type has a specific purpose and serves as a foundational element for defining infrastructure as code. Below are the key block types in Terraform:

### 1. **Provider Block**

The **`provider`** block defines the cloud providers or other services that Terraform interacts with. Providers are responsible for managing the lifecycle of resources within a specific platform (e.g., AWS, Azure, GCP).

- **Purpose**: Configures credentials, regions, or other settings for cloud providers.
  
#### Example:
```hcl
provider "aws" {
  region = "us-west-2"
}
```

### 2. **Resource Block**

The **`resource`** block is the core of Terraform, defining specific infrastructure components like virtual machines, storage, networks, etc. Each resource block represents one or more objects in your infrastructure.

- **Purpose**: To manage resources like EC2 instances, S3 buckets, VMs, etc.
  
#### Example:
```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}
```

- **Structure**:
  - `resource "<PROVIDER>_<RESOURCE_TYPE>" "<NAME>" { ... }`
  - `<PROVIDER>`: Cloud provider (e.g., `aws`, `azurerm`, `google`).
  - `<RESOURCE_TYPE>`: Type of the resource (e.g., `instance`, `bucket`).
  - `<NAME>`: Logical name to reference the resource.

### 3. **Data Block**

The **`data`** block allows you to query information about existing infrastructure resources or services from your provider without managing them directly.

- **Purpose**: Fetches information about resources not managed by Terraform, but which might be needed by other parts of the configuration.
  
#### Example:
```hcl
data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}
```

- **Structure**:
  - `data "<PROVIDER>_<DATA_SOURCE>" "<NAME>" { ... }`
  - `<PROVIDER>`: The provider.
  - `<DATA_SOURCE>`: Data source type (e.g., `ami`, `subnet`).
  - `<NAME>`: Logical name to reference the data.

### 4. **Module Block**

The **`module`** block is used to call reusable sets of Terraform configuration files (modules) that abstract common resources or infrastructure setups. Modules help reduce redundancy in Terraform code and make configurations reusable.

- **Purpose**: To reuse common infrastructure components or logical groupings of resources.
  
#### Example:
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
}
```

- **Structure**:
  - `module "<NAME>" { ... }`
  - `<NAME>`: Logical name for the module instance.

### 5. **Variable Block**

The **`variable`** block is used to define inputs that make your Terraform configurations dynamic and reusable. It allows you to pass values at runtime.

- **Purpose**: To define configurable parameters in the Terraform configuration.
  
#### Example:
```hcl
variable "instance_type" {
  description = "The type of instance to create"
  default     = "t2.micro"
}
```

- **Structure**:
  - `variable "<NAME>" { ... }`
  - `<NAME>`: Name of the variable.

### 6. **Output Block**

The **`output`** block is used to display or export useful information about the resources managed by Terraform. It allows you to print resource attributes or pass values between different modules.

- **Purpose**: To expose or share resource attributes after execution.
  
#### Example:
```hcl
output "instance_ip" {
  value = aws_instance.example.public_ip
}
```

- **Structure**:
  - `output "<NAME>" { ... }`
  - `<NAME>`: Logical name of the output.

### 7. **Locals Block**

The **`locals`** block is used to define reusable expressions or computations within your Terraform configuration. It allows you to calculate values once and use them across the configuration.

- **Purpose**: To define local values or expressions for use within the configuration.
  
#### Example:
```hcl
locals {
  instance_count = 3
  common_tags    = {
    Environment = "dev"
    Owner       = "admin"
  }
}
```

- **Structure**:
  - `locals { ... }`
  - Contains key-value pairs that can be referenced elsewhere.

### 8. **Terraform Block**

The **`terraform`** block is used for setting up global configurations, backend settings (for state storage), or required provider versions. It's not common to have multiple `terraform` blocks in a configuration file.

- **Purpose**: To configure Terraform settings like backend storage or required versions.
  
#### Example:
```hcl
terraform {
  required_version = ">= 1.1.0"

  backend "s3" {
    bucket = "my-terraform-state"
    key    = "global/s3/terraform.tfstate"
    region = "us-west-2"
  }
}
```

- **Structure**:
  - `terraform { ... }`
  - Inside this block, you can define settings like `required_version` or `backend`.

### 9. **Backend Block**

The **`backend`** block defines where Terraform stores its state. It is commonly used within the `terraform` block to configure remote state storage (e.g., on S3, GCS, Azure Blob Storage, etc.).

- **Purpose**: To configure state management and storage (local or remote).
  
#### Example:
```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "global/s3/terraform.tfstate"
    region = "us-west-2"
  }
}
```

---

### Example of Terraform Configuration Using Different Blocks

```hcl
# Provider Block
provider "aws" {
  region = "us-west-2"
}

# Resource Block
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  tags = {
    Name = "MyEC2Instance"
  }
}

# Data Block
data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

# Output Block
output "instance_public_ip" {
  value = aws_instance.example.public_ip
}

# Variable Block
variable "instance_type" {
  description = "Instance type"
  default     = "t2.micro"
}

# Locals Block
locals {
  environment = "dev"
}
```

This demonstrates how the different block types fit together in a Terraform configuration. Each block plays a role in defining, configuring, and managing cloud resources and infrastructure efficiently.

In Terraform, the **provider block** is used to configure the infrastructure provider (such as AWS, Azure, GCP, etc.) that Terraform will interact with. Providers are responsible for understanding API interactions and exposing resources within the API for Terraform to manage.

Here's a simple example of a provider block for AWS:

```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}
```

### Key elements of a provider block:
- **Provider Name:** Specifies the infrastructure provider, in this case, `aws`.
- **Region:** The region where resources will be created.
- **Profile:** (Optional) Refers to a specific AWS CLI profile for authentication.

### Additional Options:
You can also include other optional configurations, such as:

```hcl
provider "aws" {
  region              = "us-west-2"
  profile             = "my-aws-profile"
  access_key          = "your-access-key"
  secret_access_key    = "your-secret-key"
}
```

In Terraform, the **resource block** is used to define resources, which represent components of your infrastructure. Each resource block specifies a type of infrastructure (like an AWS EC2 instance, an S3 bucket, or an Azure Virtual Machine) and its desired configuration.

Here's a basic example of a resource block for an AWS EC2 instance:

```hcl
resource "aws_instance" "my_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "MyInstance"
  }
}
```

### Key Components:
- **`resource` keyword:** Defines the resource block.
- **Resource type (`aws_instance`):** Specifies the type of resource (in this case, an AWS EC2 instance).
- **Resource name (`my_ec2`):** A user-defined name that allows you to reference the resource elsewhere in the configuration.
- **Resource configuration:** Contains the resource's attributes, such as `ami` (Amazon Machine Image), `instance_type`, and `tags`.

### Example for an AWS S3 Bucket:

```hcl
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name"
  acl    = "private"

  tags = {
    Name        = "MyS3Bucket"
    Environment = "Dev"
  }
}
```

### Advanced Resource Block Features:
1. **Dependencies:** Resources can depend on other resources using the `depends_on` attribute.
   
   ```hcl
   resource "aws_instance" "my_ec2" {
     ami           = "ami-0c55b159cbfafe1f0"
     instance_type = "t2.micro"
     
     depends_on = [aws_s3_bucket.my_bucket]
   }
   ```

2. **Dynamic Blocks:** You can dynamically generate parts of a resource block using the `dynamic` block, useful for repeated or conditional sections.

```hcl
resource "aws_security_group" "example" {
  name = "example_sg"

  dynamic "ingress" {
    for_each = var.rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

Here are examples of common AWS resources you can manage with Terraform:

### 1. **AWS S3 Bucket**

```hcl
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name"
  acl    = "private"

  tags = {
    Name        = "MyS3Bucket"
    Environment = "Development"
  }
}
```
- **`aws_s3_bucket`**: Creates an S3 bucket.
- **`bucket`**: Specifies a globally unique name for the S3 bucket.
- **`acl`**: Defines the access control list (e.g., `private`, `public-read`).
- **Tags**: Metadata tags for organizing and categorizing the bucket.

### 2. **AWS EC2 Instance**

```hcl
resource "aws_instance" "my_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "MyInstance"
  }
}
```
- **`aws_instance`**: Provisions an EC2 instance.
- **`ami`**: The Amazon Machine Image (AMI) ID used to launch the instance.
- **`instance_type`**: Specifies the type of EC2 instance (e.g., `t2.micro`).

### 3. **AWS VPC (Virtual Private Cloud)**

```hcl
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MyVPC"
  }
}
```
- **`aws_vpc`**: Creates a Virtual Private Cloud (VPC).
- **`cidr_block`**: Defines the IP range for the VPC.

### 4. **AWS RDS (Relational Database Service)**

```hcl
resource "aws_db_instance" "mydb" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  name                 = "mydatabase"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true

  tags = {
    Name = "MyDB"
  }
}
```
- **`aws_db_instance`**: Creates an RDS instance.
- **`engine`**: Specifies the database engine (e.g., `mysql`).
- **`username`/`password`**: Credentials for the database admin user.
- **`allocated_storage`**: Defines the storage size (in GB).

### 5. **AWS IAM Role**

```hcl
resource "aws_iam_role" "my_role" {
  name = "my_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "MyLambdaRole"
  }
}
```
- **`aws_iam_role`**: Creates an IAM role for AWS Lambda.
- **`assume_role_policy`**: Specifies the trust policy that allows a service (like Lambda) to assume the role.

### 6. **AWS Lambda Function**

```hcl
resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.my_role.arn
  filename      = "lambda_function.zip"

  environment {
    variables = {
      stage = "dev"
    }
  }

  tags = {
    Name = "MyLambdaFunction"
  }
}
```
- **`aws_lambda_function`**: Provisions a Lambda function.
- **`runtime`**: Specifies the runtime environment (e.g., `python3.8`).
- **`handler`**: The function entry point (e.g., `lambda_function.lambda_handler`).
- **`role`**: Associates the Lambda function with an IAM role.
- **`filename`**: Specifies the deployment package for the Lambda function.

### 7. **AWS Security Group**

```hcl
resource "aws_security_group" "my_sg" {
  name        = "allow_http"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AllowHTTP"
  }
}
```
- **`aws_security_group`**: Defines a security group to control traffic.
- **`ingress`**: Allows incoming traffic (e.g., HTTP on port 80).
- **`egress`**: Controls outgoing traffic (allowing all by default here).

```markdown
# AWS DevOps Repository

Welcome to the AWS DevOps repository! This repository is dedicated to demonstrating various DevOps practices, tools, and configurations related to Amazon Web Services (AWS). Here, you will find a collection of Terraform scripts, AWS configuration files, CI/CD pipelines, and best practices for managing AWS resources effectively.

## Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
- [Terraform Configuration](#terraform-configuration)
- [AWS DevOps Practices](#aws-devops-practices)
- [Contact](#contact)

## Overview

This repository showcases a variety of AWS DevOps concepts, including:

- Infrastructure as Code (IaC) using Terraform
- CI/CD pipelines with AWS CodePipeline and AWS CodeBuild
- Monitoring and logging with AWS CloudWatch
- Security best practices for AWS resources

## Getting Started

To get started with the projects in this repository, you'll need to have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) - for infrastructure provisioning
- [AWS CLI](https://aws.amazon.com/cli/) - to interact with AWS services
- [Docker](https://www.docker.com/) - for containerization (if applicable)

### Clone the Repository

```bash
git clone https://github.com/yourusername/aws-devops.git
cd aws-devops
```

### Configuration

1. **AWS Credentials**: Ensure your AWS credentials are configured. You can do this using the AWS CLI:

   ```bash
   aws configure
   ```

2. **Terraform Initialization**: Navigate to the Terraform directory and initialize:

   ```bash
   cd terraform
   terraform init
   ```

3. **Apply Terraform Configuration**: To provision the infrastructure defined in your Terraform scripts:

   ```bash
   terraform apply
   ```

## Terraform Configuration

This repository contains various Terraform configurations for deploying AWS resources. Each directory contains specific configurations related to different services or applications.

### Example Terraform Configuration

```hcl
provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name"
  acl    = "private"
}

output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}

A **Terraform Workspace** is a feature of Terraform that allows you to manage multiple distinct instances of a single configuration. Each workspace has its own state file, enabling you to work with different environments (e.g., development, staging, production) without duplicating your code. This is particularly useful when you want to manage infrastructure for different environments but share the same configuration code.

### Key Points About Terraform Workspaces:
1. **Default Workspace**: Every Terraform project starts with a default workspace. If you don't explicitly create additional workspaces, all operations will happen in this default workspace.
   
2. **Creating Workspaces**: You can create new workspaces with the command:
   ```
   terraform workspace new <workspace_name>
   ```

3. **Switching Between Workspaces**: To switch between workspaces, use:
   ```
   terraform workspace select <workspace_name>
   ```

4. **Listing Workspaces**: You can view all available workspaces in the current directory by running:
   ```
   terraform workspace list
   ```

5. **Deleting Workspaces**: To delete a workspace, use:
   ```
   terraform workspace delete <workspace_name>
   ```
   Note that you cannot delete the default workspace.

6. **Use Case**: Workspaces are often used to create isolated environments like `dev`, `staging`, and `prod`, each having its own separate state.

7. **Limitations**: Workspaces are not suitable for every scenario. For example, they are not recommended for managing entirely different cloud providers or drastically different environments, as you may run into limitations in terms of state management and separation.

### Practical Example:
In a scenario where you're managing multiple environments (like `dev`, `staging`, `prod`), you can use workspaces to switch between environments while keeping the same infrastructure code. The Terraform state file for each workspace is stored separately, so changes to one environment won’t affect others.

### Workflow:
1. Initialize your Terraform configuration:
   ```bash
   terraform init
   ```

2. Create or switch to the required workspace:
   ```bash
   terraform workspace new dev   # Create and switch to 'dev'
   terraform workspace select prod   # Switch to 'prod'
   ```

3. Apply infrastructure changes specific to the current workspace:
   ```bash
   terraform apply
   ```
# Terraform

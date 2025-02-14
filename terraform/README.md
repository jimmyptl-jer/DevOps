To plan a **Dev, Prod, and Test** environment in Terraform, you can create separate configurations or use workspaces to isolate environments. Here are three common approaches:

### 1. **Separate Directories for Each Environment**
This is the most straightforward method, where you maintain separate directories for `dev`, `prod`, and `test`. Each directory contains its own Terraform files, including variable files (`.tfvars`) specific to the environment.

#### Directory Structure:
```bash
/terraform-project
  /dev
    - main.tf
    - variables.tf
    - terraform.tfvars
  /prod
    - main.tf
    - variables.tf
    - terraform.tfvars
  /test
    - main.tf
    - variables.tf
    - terraform.tfvars
  /modules
    /vpc
    /ec2
    /security-groups
  - provider.tf
```

- **Pros**: Clear separation of environments.
- **Cons**: Can become repetitive and harder to maintain as environments grow.

#### Example:
In each environment (`dev`, `prod`, `test`), you can have environment-specific `.tfvars`:

```hcl
# dev/terraform.tfvars
aws_region = "us-west-2"
vpc_cidr = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
instance_type = "t2.micro"
```

```hcl
# prod/terraform.tfvars
aws_region = "us-west-1"
vpc_cidr = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
instance_type = "t3.large"
```

You would initialize and apply Terraform separately for each environment:
```bash
cd dev
terraform init
terraform apply -var-file="terraform.tfvars"

cd prod
terraform init
terraform apply -var-file="terraform.tfvars"
```

### 2. **Using Terraform Workspaces**
Terraform workspaces allow you to use the same configuration files and switch between environments using the `workspace` commands. Each workspace has its own state file, keeping resources isolated across environments.

#### Example:
1. Initialize Terraform in the root directory:
   ```bash
   terraform init
   ```

2. Create or switch workspaces:
   ```bash
   terraform workspace new dev
   terraform workspace new prod
   terraform workspace new test
   ```

3. Reference the workspace in your Terraform code:
   ```hcl
   # main.tf
   variable "environment" {
     description = "The environment (dev, prod, test)"
     type        = string
   }

   resource "aws_instance" "web" {
     ami           = var.ami
     instance_type = var.instance_type

     tags = {
       Name       = "${var.instance_name}-${terraform.workspace}"
       Environment = terraform.workspace
     }
   }
   ```

4. Use environment-specific variables in your `.tfvars` files:
   ```bash
   terraform apply -var-file="dev.tfvars"
   terraform apply -var-file="prod.tfvars"
   ```

- **Pros**: Easier to manage a single set of files for multiple environments.
- **Cons**: Requires careful management of variables and the state file.

### 3. **Single Configuration with Variable Overrides**
You can use a single set of Terraform configurations and differentiate environments using `.tfvars` files or environment variables.

#### Directory Structure:
```bash
/terraform-project
  - main.tf
  - variables.tf
  - provider.tf
  - dev.tfvars
  - prod.tfvars
  - test.tfvars
  /modules
    /vpc
    /ec2
    /security-groups
```

#### `main.tf`:
In your main configuration, use variables that can be overridden per environment:

```hcl
variable "environment" {
  description = "The environment (dev, prod, test)"
  type        = string
}

resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name       = "${var.instance_name}-${var.environment}"
    Environment = var.environment
  }
}
```

#### Example `.tfvars` Files:
```hcl
# dev.tfvars
aws_region = "us-west-2"
vpc_cidr = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
instance_type = "t2.micro"
environment = "dev"
```

```hcl
# prod.tfvars
aws_region = "us-west-1"
vpc_cidr = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
instance_type = "t3.large"
environment = "prod"
```

You can apply the configurations to different environments using the respective `.tfvars` files:

```bash
terraform apply -var-file="dev.tfvars"
terraform apply -var-file="prod.tfvars"
```

- **Pros**: One central configuration, reduced duplication.
- **Cons**: Requires attention when switching environments and managing state.

### Recommendation:
- For **small to medium** projects, using **separate directories** is often simpler and more manageable.
- For **larger teams or automation**, **Terraform workspaces** or **single configuration with .tfvars** files is more scalable.

Would you like help setting up one of these approaches?
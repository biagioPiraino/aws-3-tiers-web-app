# Three-Tier Cloud Architecture
<h3>Description</h3>
<p>Deploy a secure three-tier cloud architecture on AWS using <strong>Terraform</strong>.<p>
<hr>

<h3>Architecture</h3>
<img src="./aws-three-tiers.png?raw=true" width="300">
<hr>

<h3>How to use</h3>
<table>
  <thead>
    <tr>
      <th>Architecture</th>
      <th>Instructions</th>
    </tr>
  </thead>
  <tbody>
    <td>Three-tier architecture</td>
    <td>
      <ol>
        <li>
          Specify an <em>access and secret key</em> of an AWS account in the <em>provider</em> section inside the <em>init.tf</em> script.
         </li>
         <li>
          Specify an SSH key pair in the <em>aws_key_pair</em> section inside the <em>computing.tf</em> script.
         </li>
          <li>
             Run <em>terraform init</em> -> <em>terraform plan</em> -> <em>terraform apply</em> from your terminal.
          </li>
      </ol>
    </td>
  </tbody>
</table>
<hr>

<h3>References</h3>
<table>
  <thead>
    <tr>
      <th>References</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <a href="https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.23.0" rel="noopener noreferrer">Create a VPC using Terraform modules
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint" rel="noopener noreferrer">Create a VPC endpoint using Terraform
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance" rel="noopener noreferrer">Create an EC2 instance using Terraform
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group" rel="noopener noreferrer">Create a Security Group using Terraform
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair" rel="noopener noreferrer">Create a Key Pair using Terraform
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance" rel="noopener noreferrer">Create a DB instance using Terraform
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group" rel="noopener noreferrer">Create a DB subnet group using Terraform
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket" rel="noopener noreferrer">Create a S3 bucket using Terraform
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document" rel="noopener noreferrer">Create an IAM policy document using Terraform
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy" rel="noopener noreferrer">Create a S3 bucket policy using Terraform
        </a>
      </td>
    </tr>
  </tbody>
</table>

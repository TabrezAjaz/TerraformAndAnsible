# TravelMemory deployment with Terraform and Ansible

This repository is the complete implementation for the graded assignment **Deploying a MERN Application through Terraform and Ansible**. Terraform provisions two Ubuntu EC2 instances in an AWS VPC; Ansible installs, secures, builds, and runs the required [TravelMemory](https://github.com/UnpredictablePrashant/TravelMemory) application.

**Live deployment:** [http://13.233.113.78](http://13.233.113.78) (available while the assignment AWS resources remain running).

![Architecture](docs/screenshots/architecture.svg)

## Assignment coverage

| Requirement | Implementation |
|---|---|
| VPC, public/private subnet | `terraform/main.tf` |
| Internet Gateway, NAT Gateway, route tables | `terraform/main.tf` |
| Public web EC2 and private MongoDB EC2 | `terraform/main.tf` |
| Restricted SSH, web/database security groups | `terraform/main.tf` |
| IAM role | SSM and CloudWatch managed policies, attached through an instance profile |
| Public IP output | `web_public_ip` and `application_url` outputs |
| Ansible connectivity | Terraform-generated inventory with the web host as SSH bastion |
| Node.js, NPM, React, Express | `ansible/roles/web` |
| Secured MongoDB and users | `ansible/roles/mongodb` |
| Environment and service management | protected `.env`, systemd, and Nginx templates |
| Hardening | IMDSv2, encrypted EBS, least-access SGs, UFW, key-only SSH, no root login |

## Prerequisites

- An AWS account and an IAM identity allowed to manage VPC, EC2, IAM, and related networking resources.
- AWS CLI authenticated using `aws configure` or another standard credential-chain method.
- Terraform 1.5 or later.
- Ansible Core 2.15 or later, OpenSSH, `curl`, and `openssl`. On Windows, run these inside WSL2.
- An existing EC2 key pair in the target region and its private PEM file.
- Your current public IPv4 address in `/32` CIDR notation.

> A NAT Gateway and two EC2 instances incur AWS charges. Run the destroy script when evidence collection is complete.

## Deploy

1. Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars`.
2. Set `admin_cidr`, `key_name`, `private_key_path`, region, and optionally the AWS profile.
3. From WSL/Linux, run `chmod +x scripts/*.sh && ./scripts/deploy.sh`.
4. Open the printed `application_url` and add a travel experience.
5. Run `./scripts/validate.sh` and capture the evidence listed in `docs/screenshots/README.md`.

The deployment script generates strong MongoDB passwords under the ignored `.secrets` directory. Never commit that directory, Terraform state, PEM files, or generated inventory.

## Manual workflow

Run Terraform `init`, `plan`, and `apply` in the `terraform` directory. Terraform writes `ansible/inventory.ini`. Export `MONGODB_ADMIN_PASSWORD` and `MONGODB_APP_PASSWORD` (minimum 16 characters), install `ansible/requirements.yml`, then run `ansible-playbook ansible/site.yml` with `ANSIBLE_CONFIG` pointing to `ansible/ansible.cfg`.

## Validate and clean up

The validation script checks the React page, Express health endpoint, and MongoDB-backed trip endpoint. After taking screenshots, run `./scripts/destroy.sh` and verify that Terraform reports all managed resources destroyed.

## Documentation

- [Detailed implementation report](docs/IMPLEMENTATION_REPORT.md)
- [Evidence checklist](docs/screenshots/README.md)
- [Original assignment](assignment.md)

## Security notes

MongoDB has no public IP, listens only on loopback and its private interface, requires authentication, and accepts network traffic only from the web security group. The web instance exposes only HTTP publicly; SSH is restricted to `admin_cidr`. HTTPS is not enabled because the assignment supplies no domain name. For a production deployment, add Route 53, an ACM certificate, an HTTPS load balancer, backups, secret rotation, and multiple Availability Zones.

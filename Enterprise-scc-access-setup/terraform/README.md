# Continuous monitoring of child accounts using Enterprise IAM and SCC

  This terraform example is a companion to the use case described in the blog post [Continuous monitoring of child accounts using Enterprise IAM and SCC](tbd) which details how to use Enterprise IAM templates and IBM Cloud Security and Compliance Center (SCC) to continously monitor child accounts in tyour enterprise.

The files used by this tutorial are:

- [scc-enterprise-access-setup.tf](./scc-enterprise-access-setup.tf): Terraform file to manage Trusted profile and permissions needed by SCC.
- [scc-enterprise-access-setup.tfvars](./scc-enterprise-access-setup.tfvars): Variables file used as input to the terraform file.

## Create and assign a trusted profile template with access for SCC instance CRN

  Update [scc-enterprise-access-setup.tfvars](./scc-enterprise-access-setup.tfvars) file to include your apikey credential, the target account group or account where to assign the template and your SCC instance's CRN.
After `tf apply -var-file="scc-enterprise-access-setup.tfvars` command completes, the following will be completed:

- A trusted profile template for the SCC instance to use
- 3 access policy templates:
  - Administrator access to Kubernetes service
  - Reader access to all IAM enabled services
  - Viewer access to all Account Management services

  After the terraform process completes, refer to the [Register child accounts as trgets in SCC](tbd) section for next steps.

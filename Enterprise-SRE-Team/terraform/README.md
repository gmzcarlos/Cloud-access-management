# Get started with Enterprise-IAM: case study Enterprise SRE team

 Enterprise-managed IAM enables cloud administrators to centrally configure access and security settings for the entire organization. To learn about the basics, see [How enterprise-managed IAM works](https://test.cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-access-enterprises#how-enterprise-iam). 
The case study below shows how to easily and securely implement and manage an SRE team's access across an enterprise using Terraform.

The file used by this tutorial are:

- [SRE-Team.tf](./SRE-Team.tf)
- [SRE-Team-v2.tf](./SRE-Team-v2.tf)

## Create and assign a trusted profile template with access for SRE team

  Update [SRE-Team.tf](./SRE-Team.tf) file to include your apikey credential, the target account group or account where to assign the template. and your IDPs claim rule to match the SRE team.
After `tf apply` command completes, a trusted profile template with Administrator access to Kubernetes and MongoDB services will be assigned to the account group. Your SRE team will be able to assume the trusted profile for any of the accounts under the account group selected.


## Grant additional access to the SRE team trusted profile

  Similarly, update [SRE-Team-v2.tf](./SRE-Team-v2.tf) file as the previous step.
After `tf apply` command completes, the SRE team will have Administrator access to Cloudant services in addition to the previous access.

All done.

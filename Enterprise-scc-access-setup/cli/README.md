# SCC Enteprise access setup with IAM tamplates

  This CLI example is a companion to the use case described in the blog post [Continuous monitoring of child accounts using Enterprise IAM and SCC](tbd) which details how to use Enterprise IAM templates and IBM Cloud Security and Compliance Center (SCC) to continously monitor child accounts in your enterprise.

The file used by this tutorial are:

- [kube-admin-ap-template.json](./kube-admin_ap-template.json)
- [service-reader-ap-template.json](./service-reader-ap-template.json)
- [account-reader-ap-template.json](./account-reader-ap-template.json)
- [scc-instance-tp-template.json](./scc-instance-tp-template.json)

## Create and assign a trusted profile template with access for SCC instance

1. Frst, update the access policy template files to add the enterprise account id.

```BASH
   "account_id": "<enterprise account id>"
```

2. Create the policy templates

```BASH
ibmcloud iam access-policy-template-create --file kube-admin_ap-template.json
ibmcloud iam access-policy-template-create --file service-reader-ap-template.json
ibmcloud iam access-policy-template-create --file account-reader-ap-template.json
```

3. List the access policy templates to get their IDs

```BASH
$ ibmcloud iam ap-templates
Name                    ID                                                    Version   Committed
Kube_Administrator      policyTemplate-59ef9218-f3d0-4f1f-a97d-6303493c7fea   1         false
Services_Reader         policyTemplate-e76bb24c-3e28-4259-a644-7dfaea3f97f8   1         false
Account_Management_Services_Reader   policyTemplate-e76bb24c-3e28-4259-a644-7dfaea3f97f8   1         false
```

4. Update the trusted profile template file to add the enterprise account id, the access policy template ids and the SCC instance CRN.

```JSON
...
"account_id": "<enterprise account id>",
...
"profile": {
    "name": "Enterprise SCC access",
    "identities": [
        {
            "type": "crn",
            "identifier": "<scc instance CRN>"
        }
    ]
},
...
"policy_template_references": [
        {
            "id": "policyTemplate-59ef9218-f3d0-4f1f-a97d-6303493c7fea",
            "version": "1"
        },
        {
            "id": "policyTemplate-e76bb24c-3e28-4259-a644-7dfaea3f97f8",
            "version": "1"
        },
        {
            "id": "policyTemplate-7bb24c-3e28-4259-a644-7dfaea3f97f8",
            "version": "1"
        }
    ]
```

5. Create the trusted profile template

```BASH
ibmcloud iam trusted-profile-template-create --file scc-instance-tp-template.json
```

6. Commit the trusted profile template

```BASH
ibmcloud iam trusted-profile-template-version-commit SCC_Enterprise_Instance 1
```

7. List the trusted profile templates to get the template id

```BASH
ibmcloud iam tp-template-version SCC_Enterprise_Instance 1
Getting version of template SCC_Enterprise_Instance as cfgomez@us.ibm.com under account e3aa0adff348470f803d4b6e53d61024
OK

Account ID            e3aa0adff348470f803d4b6e1024
Name                  SCC_Enterprise_Instance
ID                    ProfileTemplate-c7962a88-1e5c-4863-b7c4-f2933ce82b0c <-- need this id
Version               1
Profile Name          Enterprise SCC access
...
```

8. Assign the trusted profile to the account group. The account group id can be listed with `ibmcloud enterprise account-groups`

```BASH
ibmcloud iam trusted-profile-assignment-create ProfileTemplate-c7962a88-1e5c-4863-b7c4-f2933ce82b0c 1 --target-type AccountGroup --target <account group id>
```

9. The assignment operation is asynchronous, to the check its status use the following command:

```BASH
ibmcloud iam trusted-profile-assignment TemplateAssignment-20f46754-b3f0-4f2a-8a4f-0d32981e7e37

ID                    TemplateAssignment-20f46754-b3f0-4f2a-8a4f-0d32981e7e37
Account ID            ...
Template ID           ProfileTemplate-c7962a88-1e5c-4863-b7c4-f2933ce82b0c
Template Version      1
Target Type           AccountGroup
Target                ...
Status                in_progress
...
```

After the operation completes, that is the status is `success`, refer to the [Register child accounts as trgets in SCC](tbd) section for next steps.

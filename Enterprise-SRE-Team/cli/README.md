# Get started with Enterprise-IAM: case study Enterprise SRE team

 Enterprise-managed IAM enables cloud administrators to centrally configure access and security settings for the entire organization. To learn about the basics, see [How enterprise-managed IAM works](https://test.cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-access-enterprises#how-enterprise-iam). The case study below shows how to easily and securely implement and manage an SRE team's access across an enterprise using [IBM Cloud CLI](https://github.com/IBM-Cloud/ibm-cloud-cli-release). This use case can also be accomplished via [UI]() and [Terraform]().

The file used by this tutorial are:

- [kube-admin_ap-template.json](./kube-admin_ap-template.json)
- [monoDb-admin_ap-template.json](./mongoDb-admin_ap-template.json)
- [cloudant-admin_ap-template.json](./cloudant-admin_ap-template.json)
- [SRE-Team_tp-template.json](./SRE-Team_tp-template.json)

## Create and assign a trusted profile template with access for SRE team

1. Frst, update the access policy template files to add the enterprise account id.

```BASH
   "account_id": "<enterprise account id>"
```

2. Create the policy templates

```BASH
ibmcloud iam access-policy-template-create --file kube-admin_ap-template.json
ibmcloud iam access-policy-template-create --file mongoDb-admin_ap-template.json
```

3. Commit the policy templates

```BASH
ibmcloud iam access-policy-template-version-commit Kube_Administrator 1
ibmcloud iam access-policy-template-version-commit MongoDB_Administrator 1
```

4. List the access policy templates to get their IDs

```BASH
$ ibmcloud iam ap-templates
Name                    ID                                                    Version   Committed
Kube_Administrator      policyTemplate-59ef9218-f3d0-4f1f-a97d-6303493c7fea   1         false
MongoDB_Administrator   policyTemplate-e76bb24c-3e28-4259-a644-7dfaea3f97f8   1         false
```

5. Update the trusted profile template file to add the enterprise account id, both access policy template ids and the SAML assertion(s) from your IDP provider.

```JSON
...
"account_id": "<enterprise account id>",
...
"profile": {
        "name": "Enterprise SRE Team",
        "rules": [
            {
                "type": "Profile-SAML",
                "realm_name": "<enter your realm name>",
                "expiration": 3600,
                // update the condition to match your organization setup
                "conditions": [ 
                    {
                        "claim": "team",
                        "operator": "EQUALS",
                        "value": "\"SRE Team\""
                    }
                ]
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
        }
    ]
```

6. Create the trusted profile template

```BASH
ibmcloud iam trusted-profile-template-create --file SRE-Team_tp-template.json
```

7. Commit the trusted profile template

```BASH
ibmcloud iam trusted-profile-template-version-commit SRE_Team 1
```

8. List the trusted profile templates to get the template id

```BASH
ic iam tp-template-version SRE_Team 1
Getting version of template SRE_Team as cfgomez@us.ibm.com under account e3aa0adff348470f803d4b6e53d61024
OK

Account ID            e3aa0adff348470f803d4b6e1024
Name                  SRE_Team
ID                    ProfileTemplate-c7962a88-1e5c-4863-b7c4-f2933ce82b0c <-- need this id
Version               1
Profile Name          Enterprise SRE Team
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


## Grant additional access to the SRE team trusted profile

1. Create a new access policy template

```BASH
ibmcloud iam access-policy-template-create --file cloudant-admin_ap-template.json
```

2. Commit the policy templates

```BASH
ibmcloud iam access-policy-template-version-commit Cloudant_Administrator 1
```

3. List the access policy template to get the ID

```BASH
$ ibmcloud iam ap-template-version Cloudant_Administrator 1

ID                    policyTemplate-243c4d6a-b679-4111-ad23-de604a1c8ae8
Version               1
Committed             true
Name                  Cloudant_Administrator
Description           Grant Administrator role to Cloudant service
...
```

4. Now we can either create a copy of `SRE-Team_tp-template.json` or update it to add the new policy template id to the trusted profile template file as follows

```JSON
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
            "id": "policyTemplate-243c4d6a-b679-4111-ad23-de604a1c8ae8",
            "version": "1"
        }
    ]
```

5. Create a new trusted profile template version

```BASH
ibmcloud iam trusted-profile-template-version-create SRE_Team --file SRE-Team_tp-template-v2.json
```

6. Commit the trusted profile template version

```BASH
ibmcloud iam trusted-profile-template-version-commit SRE_Team 2
```

7. Update the existing assignment, using the ID from step 9 in the previous section.

```BASH
ibmcloud iam trusted-profile-assignment-update {ASSIGNMENT_ID} 2
```

All done.

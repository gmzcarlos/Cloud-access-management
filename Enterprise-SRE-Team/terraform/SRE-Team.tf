terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.77.1"
    }
  }
}

variable "apikey" {
 type = string
 description = "Apikey with access to Create and assign IAM templates"
 nullable = false
}

variable "assignment_target_type" {
  type = string
  description = "Assigning to a single Account or an AccountGroup"
  nullable = false
}

variable "assignment_target" {
  type = string
  description = "Account Id or Account Group Id where to assign the template"
  nullable = false
}

provider "ibm" {
  ibmcloud_api_key = var.apikey
}

# Create Kubernetes administrator policy template
resource "ibm_iam_policy_template" "Kube_Administrator_ap_template" {
	name = "Kube_Administrator"
	description = "Grant Administrator and Manager roles to Kube service"
	committed = true
	policy {
		type = "access"
		resource {
			attributes {
				key = "serviceName"
				operator = "stringEquals"
				value = "containers-kubernetes"
			}
		}
		roles = ["Administrator", "Manager"]
	}
}

# Create MongoDb administrator policy template
resource "ibm_iam_policy_template" "MongoDb_Administrator_ap_template" {
	name = "MongoDb_Administrator"
	description = "Grant Administrator role to MongoDb service"
	committed = true
	policy {
		type = "access"
		resource {
			attributes {
				key = "serviceName"
				operator = "stringEquals"
				value = "databases-for-mongodb"
			}
		}
		roles = ["Administrator"]
	}
}

# Create SRE team Trusted profile template
resource "ibm_iam_trusted_profile_template" "SRE_Team_tp_template" {
  name = "SRE_Team"
  description = "SRE Team access"
  profile {
    name = "Enterprise SRE Team"
    rules {
      type = "Profile-SAML"
      realm_name = "https://myIdp.mycompany.com"
      expiration = 3600
      conditions {
        claim = "Team"
        operator = "EQUALS"
        value = "\"SRE\""
      }
    }
  }
  policy_template_references {
	# id = split("/", ibm_iam_policy_template.Kube_Administrator_ap_template.id)[0]
	id = ibm_iam_policy_template.Kube_Administrator_ap_template.template_id
	version = ibm_iam_policy_template.Kube_Administrator_ap_template.version
  }
  policy_template_references {
	# id = split("/", ibm_iam_policy_template.MongoDb_Administrator_ap_template.id)[0]
	id = ibm_iam_policy_template.MongoDb_Administrator_ap_template.template_id
	version = ibm_iam_policy_template.MongoDb_Administrator_ap_template.version
  }
  committed = true
}

# Assign (or update) the trusted profile template to an account agroup
resource "ibm_iam_trusted_profile_template_assignment" "tp_assignment_instance" {
  template_id = split("/", ibm_iam_trusted_profile_template.SRE_Team_tp_template.id)[0]
  template_version = ibm_iam_trusted_profile_template.SRE_Team_tp_template.version
  target_type = var.assignment_target_type
  target = var.assignment_target
  depends_on = [
    ibm_iam_trusted_profile_template.SRE_Team_tp_template
  ]
}

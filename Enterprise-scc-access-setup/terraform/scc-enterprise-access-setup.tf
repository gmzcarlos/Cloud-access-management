terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = ">= 1.64.2"
    }
  }
}

variable "apikey" {
 type = string
 description = "Apikey with access to Create and assign IAM templates"
 nullable = false
}

variable "scc_instance_crn" {
    type = string
    description = "Full SCC instance crn"
	nullable = false
}

variable "assignment_target_type" {
    type = string
    description = "Assigning to a single account or an account group"
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
	description = "Grant required roles to Kube service"
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
		roles = ["Administrator", "Viewer", "Reader", "Service Configuration Reader"]
	}
}

# Create Services ConfigReader policy template
resource "ibm_iam_policy_template" "Services_Reader_ap_template" {
	name = "Services_Reader"
	description = "Grant Reader, Viewer, ConfigReader roles to all service in account"
	committed = true
	policy {
		type = "access"
		resource {
			attributes {
				key = "serviceType"
				operator = "stringEquals"
				value = "service"
			}
		}
		roles = ["Reader", "Viewer", "Service Configuration Reader"]
	}
}

# Create Account Management Services ConfigReader policy template
resource "ibm_iam_policy_template" "Account_Management_Services_Reader_ap_template" {
	name = "Account_Management_Services_Reader"
	description = "Grant Reader, Viewer, ConfigReader roles to all account management services in the account"
	committed = "true"
	policy {
		type = "access"
		resource {
			attributes {
				key = "serviceType"
				operator = "stringEquals"
				value = "platform_service"
			}
		}
		roles = ["Viewer", "Service Configuration Reader"]
	}
}

# Create Enterprise SCC instance Trusted profile template
resource "ibm_iam_trusted_profile_template" "SCC_Instance_tp_template" {
  name = "Enterprise_SCC"
  description = "Enterprise SCC access"
  profile {
    name = "Enterprise SCC Instance"
    identities {
      type = "crn"
      iam_id = format("crn-%s", var.scc_instance_crn)
      identifier = var.scc_instance_crn
    }
  }
  policy_template_references {
	id = split("/", ibm_iam_policy_template.Kube_Administrator_ap_template.id)[0]
	version = ibm_iam_policy_template.Kube_Administrator_ap_template.version
  }
  policy_template_references {
	id = split("/", ibm_iam_policy_template.Services_Reader_ap_template.id)[0]
	version = ibm_iam_policy_template.Services_Reader_ap_template.version
  }
  policy_template_references {
	id = split("/", ibm_iam_policy_template.Account_Management_Services_Reader_ap_template.id)[0]
	version = ibm_iam_policy_template.Account_Management_Services_Reader_ap_template.version
  }
  committed = true
}

# Assign (or update) the trusted profile template to an account agroup
resource "ibm_iam_trusted_profile_template_assignment" "SCC_Instance_tp_template" {
  template_id = split("/", ibm_iam_trusted_profile_template.SCC_Instance_tp_template.id)[0]
  template_version = ibm_iam_trusted_profile_template.SCC_Instance_tp_template.version
  target_type = var.assignment_target_type // or "Account" or "AccountGroup"
  target = var.assignment_target // Account name: "Testing"
  depends_on = [
    ibm_iam_trusted_profile_template.SCC_Instance_tp_template
  ]
}

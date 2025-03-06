resource "azuread_conditional_access_policy" "adm_s_limit_admin_sessions" {
  display_name = "ADM - S - Limit admin sessions"
  state        = "enabled"

    conditions {
    users {
      included_roles = var.admin_roles
      included_groups = [var.admin_groups.admin_user_group]
      excluded_groups = [var.admin_groups.emergency_access_group]
    }

    applications {
      included_applications = ["all"]
      excluded_applications = []
    }

    client_app_types = ["browser", "mobileAppsAndDesktop"]
  }

    
session_controls {
    sign_in_frequency        = 4      # Re-authentication required every 4 hours
    sign_in_frequency_period = "hours"
  }

  grant_controls {
    operator          = "AND"
    built_in_controls = ["mfa"] # Require Multi-Factor Authentication (MFA)
}
}

resource "azuread_conditional_access_policy" "block_unapproved_devices" {
  display_name = "DEV - B - Block access from unapproved devices"
  state        = "enabled"

  conditions {
    users {
      included_users = ["all"]
    }

    applications {
      included_applications = ["all"]
    }

    devices {
      filter {
        mode = "include"
        rule = "device.trustType -ne 'AzureAD'"
      }
    }

    platforms {
      included_platforms = ["android", "windowsPhone"] 
      excluded_platforms = ["iOS"] 
    }
   client_app_types = ["browser", "mobileAppsAndDesktop"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

resource "azuread_conditional_access_policy" "require_compliant_devices" {
  display_name = "DEV - G - Compliant devices"
  state        = "enabled"

  conditions {
    users {
      included_users  = ["all"]  
      excluded_users  = []      

    }

    applications {
      included_applications = ["all"] 
      excluded_applications = []       
    }

    client_app_types = ["browser", "mobileAppsAndDesktop"] 

    devices {
      filter {
        mode = "include"
        rule = "device.isCompliant -eq true"  # Requires compliant devices
      }
    }
  }

  grant_controls {
    operator          = "AND"
    built_in_controls = ["require_compliant_device"] # ✅ Enforce device compliance
  }
}

resource "azuread_conditional_access_policy" "require_intune_enrollment" {
  display_name = "DEV - G - Intune enrolment with strong auth"
  state        = "enabled"

  conditions {
    users {
      included_users  = ["all"] 
    }

    applications {
      included_applications = ["all"] 
      excluded_applications = []       
    }

    client_app_types = ["browser", "mobileAppsAndDesktop"]  #  Covers all client app types

    devices {
      filter {
        mode = "include"
        rule = "device.trustType -eq 'AzureADRegistered' -or device.trustType -eq 'AzureADJoined' -or device.trustType -eq 'HybridAzureADJoined'"
      }
    }
  }

  grant_controls {
    operator          = "AND"
    built_in_controls = ["require_mfa", "require_compliant_device", "require_approved_client_app"] # ✅ Requires MFA, Compliant Device, Approved Apps
  }
}
resource "azuread_conditional_access_policy" "block_guests" {
  display_name = "GST - B - Block guests"
  state        = "enabled"

  conditions {
    users {
      included_users = var.guest_user_types
      excluded_groups = var.guest_exclusion_group_block_guests_id 
    }

     applications {
      included_applications = ["all"]  
      excluded_applications = []       
    }

    client_app_types = ["all"]
  }

  grant_controls {
    operator = "OR"
    built_in_controls = ["block"]
  }
}
resource "azuread_conditional_access_policy" "guest_application_access" {
  display_name = "GST - G - Guest application access with strong auth"
  state        = "enabled"

  conditions {
    users {
      included_users = var.guest_user_types
      excluded_groups = var.guest_exclusion_group_id
    }

    applications {
    included_applications = ["<application_id>"]  # Replace <application_id> with the actual app ID
    excluded_applications = []
  }

    client_app_types = ["all"]
  }

  grant_controls {
    operator = "OR"  # Ensures only one of the selected controls is required
    built_in_controls = ["authentication_strength"]
    authentication_strength_policy_id = var.authentication_strength_policy_id
  }
}


resource "azuread_conditional_access_policy" "block_unapproved_countries" {
  display_name = "LOC - B - Block access from unapproved countries"
  state        = "enabled"

  conditions {
    users {
      included_users = ["All"]  # Apply to all users
      excluded_users = []      
    }

    applications {
      included_applications = ["All"]  # Apply to all applications
      excluded_applications = []      
    }

    locations {
      included_locations = ["All"]  # Apply to all locations (global scope)
      excluded_locations =  var.location_ids
    }

    client_app_types = ["all"]  # Apply to all client applications
  }

  grant_controls {
    operator = "OR"
    built_in_controls = ["block"]  # Block access from unapproved locations
  }
}
resource "azuread_conditional_access_policy" "usr_b_block_legacy_auth" {
  display_name = "USR - B - Block access via legacy auth"
  state        = "enabled"

  conditions {
    users {
      included_users = ["all"]
      excluded_groups = [var.admin_groups.excluded_group_usr_b]
    }

    applications {
      included_applications = ["all"]
      excluded_applications = []
    }

    client_app_types = ["exchangeActiveSync", "other"]
  }

  grant_controls {
    operator = "OR"
    built_in_controls = ["block"]
  }
}
resource "azuread_conditional_access_policy" "usr_b_block_high_risk_signins" {
  display_name = "USR-B-Block high-risk sign-ins"
  state        = "enabled"

  conditions {
    users {
      included_users = ["all"]
      excluded_groups = []
    }

    applications {
      included_applications = ["all"]
      excluded_applications = []
    }
    client_app_types = ["all"]
    
    sign_in_risk_levels = ["high"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

resource "azuread_conditional_access_policy" "usr_b_block_high_risk_users" {
  display_name = "USR - B - Block high-risk users"
  state        = "enabled"

  conditions {
    users {
      included_users = ["all"]
      excluded_groups = []
    }

    applications {
      included_applications = ["all"]
      excluded_applications = []
    }
    client_app_types = ["all"]
    user_risk_levels = ["high"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}
resource "azuread_conditional_access_policy" "usr_b_block_elevated_insider_risk" {
  display_name = "USR - B - Block users with elevated insider risk"
  state        = "enabled"

  conditions {
    users {
      included_users  = ["all"]
      excluded_groups = [var.admin_groups.excluded_group_usr_b_insider_risk]
      
    }

    applications {
      included_applications = ["all"]
      excluded_applications = []
    }
    client_app_types = ["all"]

    insider_risk_levels = ["high"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

resource "azuread_conditional_access_policy" "usr_g_require_terms_of_use" {
  display_name = "USR - G - Agreement to terms of use"
  state        = "enabled"

  conditions {
    users {
      included_users  = ["all"]
      excluded_groups = [var.admin_groups.excluded_group_usr_g_term_of_use]
   
    }

    applications {
      included_applications = ["all"]
      excluded_applications = []
    }

    client_app_types = ["all"]
  }

  grant_controls {
    operator          = "OR"
    terms_of_use      = [var.terms_of_use_id]
  }
}
resource "azuread_conditional_access_policy" "usr_g_register_security_info" {
  display_name = "USR - G - Register security info with strong auth"
  state        = "enabled"

  conditions {
    users {
      included_users  = ["all"]
      excluded_groups = [var.admin_group.excluded_group_usr_g_register_security_info]
    }

    applications {
      included_user_actions = ["urn:user:registersecurityinfo"] # Applies to "Register security information"
    }

    client_app_types = ["all"]
  }

  grant_controls {
    operator                         = "OR"  # Ensures only one of the selected controls is required
    built_in_controls                 = ["authentication_strength"]
    authentication_strength_policy_id = var.authentication_strength_policy_id_usr_g
  }
}
resource "azuread_conditional_access_policy" "usr_g_strong_authentication" {
  display_name = "USR - G - Require strong auth"
  state        = "enabled"

  conditions {
    users {
      included_users  = ["all"]
      excluded_groups = [var.admin_groups.excluded_group_usr_g_strong_auth] # Replace with actual group if applicable
    }

    applications {
      included_applications = ["all"]
      excluded_applications = []
    }

    client_app_types = ["all"]
  }

  grant_controls {
    operator                         = "OR"  # Ensures only one of the selected controls is required
    built_in_controls                 = ["authentication_strength"]
    authentication_strength_policy_id = var.authentication_strength_policy_id_usr_g
  }
}

resource "azuread_conditional_access_policy" "usr_g_reauth_risky_signins" {
  display_name = "USR - G - risky sign-ins with strong auth"
  state        = "enabled"

  conditions {
    users {
      included_users  = ["all"]
      excluded_groups = [var.admin_groups.excluded_group_usr_g_reauth] 
    }

    applications {
      included_applications = ["all"]
      excluded_applications = []
    }

    client_app_types = ["all"]

    sign_in_risk_levels = ["low", "medium"]
  }

  grant_controls {
    operator                         = "OR"  # Ensures only one of the selected controls is required
    built_in_controls                 = ["require_mfa"]
    authentication_strength_policy_id =  var.authentication_strength_policy_id_usr_g
  }
}

resource "azuread_conditional_access_policy" "usr_s_limit_user_sessions" {
  display_name = "USR - S - Limit user sessions"
  state        = "enabled"

  conditions {
    users {
      included_users  = ["all"]
      excluded_roles  = var.excluded_admin_roles
      excluded_groups = var.admin_roles.excluded_group_usr_s
    }
    client_app_types = ["all"]

    applications {
      included_applications = ["all"]
      excluded_applications = []
    }
  }

 session_controls {
      sign_in_frequency =          16
      sign_in_frequency_interval            = "timeBased"
      sign_in_frequency_period              = "hours"
    }
}



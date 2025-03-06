output "admin_groups" {
  description = "Admin groups used in conditional access policies."
  value       = var.admin_groups
}

output "guest_user_types" {
  description = "List of guest user types included in policies."
  value       = var.guest_user_types
}

output "guest_exclusion_group_id" {
  description = "Guest exclusion group ID."
  value       = var.guest_exclusion_group_id
}

output "authentication_strength_policy_id" {
  description = "Authentication strength policy ID."
  value       = var.authentication_strength_policy_id
}

output "location_ids" {
  description = "List of location IDs used in location-based policies."
  value       = var.location_ids
}

output "terms_of_use_id" {
  description = "Terms of use policy ID."
  value       = var.terms_of_use_id
}

output "conditional_access_policies" {
  description = "List of deployed Conditional Access Policies."
  value = [
    azuread_conditional_access_policy.adm_s_limit_admin_sessions.display_name,
    azuread_conditional_access_policy.block_unapproved_devices.display_name,
    azuread_conditional_access_policy.require_compliant_devices.display_name,
    azuread_conditional_access_policy.require_intune_enrollment.display_name,
    azuread_conditional_access_policy.block_guests.display_name,
    azuread_conditional_access_policy.guest_application_access.display_name,
    azuread_conditional_access_policy.block_unapproved_countries.display_name,
    azuread_conditional_access_policy.usr_b_block_legacy_auth.display_name,
    azuread_conditional_access_policy.usr_b_block_high_risk_signins.display_name,
    azuread_conditional_access_policy.usr_b_block_high_risk_users.display_name,
    azuread_conditional_access_policy.usr_b_block_elevated_insider_risk.display_name,
    azuread_conditional_access_policy.usr_b_require_terms_of_use.display_name,
    azuread_conditional_access_policy.usr_g_register_security_info.display_name,
    azuread_conditional_access_policy.usr_g_strong_authentication.display_name,
    azuread_conditional_access_policy.usr_g_reauth_risky_signins.display_name,
    azuread_conditional_access_policy.usr_s_limit_user_sessions.display_name
  ]
}

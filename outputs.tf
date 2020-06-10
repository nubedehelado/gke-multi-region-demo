output "service_account_name" {
  description = "The service account name."
  value       = module.service_accounts.service_account
}

output "service_account_key" {
  description = "The service account key."
  value       = module.service_accounts.key
}
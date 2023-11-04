## Unreleased

BACKWARDS INCOMPATIBILITIES / NOTES:

* This module is now compatible with Terraform 1.3 and higher.
* This module is now compatible with the AWS provider version 4.0 or greater.
* The `idle_timeout` variable has now been removed as it is not compatible with
  NLBs.
* The `use_https` variable has been removed as it is not used.
* The `target_group_port`, `target_group_type`, `target_group_protocol`, 
  `health_check_port`, `health_check_protocol`, `health_check_interval`,
  `health_check_unhealthy_threshold`, `health_check_healthy_threshold` variables
  have been removed in favour of the `target_groups` variable which allows an
  arbitrary number of target groups to be created.
* The `listener_port`, `listener_protocol` and `listener_certificate_arn` 
  variables have been removed in favour of the `listeners` variable which allows
  an arbitrary number of listeners to be created.
* The `domain_name`, `public_zone_id`, `private_zone_id`, 
  `include_public_dns_record` and `include_private_dns_record` variables have
  been removed in favour of the `dns` variable which allows an arbitrary number 
  of records to be created.

IMPROVEMENTS:

* An `enable_deletion_protection` variable has been added, allowing deletion
  protection to be enabled for the load balancer.
* An `enable_access_logs` variable has been added, along with 
  `access_logs_bucket_name` and `access_logs_bucket_prefix` variables, allowing
  access logs to be configured for the load balancer.

## 2.0.0 (May 28th, 2021)

BACKWARDS INCOMPATIBILITIES / NOTES:

* This module is now compatible with Terraform 0.14 and higher.

## 0.1.4 (September 9th, 2017) 

IMPROVEMENTS:

* The zone ID and the DNS name of the ELB are now output from the module.   
output "alb_hostname" {
    value = "${aws_alb.main_alb.dns_name}"
}

output "Service_Discovery_ID" {
    value = "${aws_service_discovery_service.sd_service.id}"
}
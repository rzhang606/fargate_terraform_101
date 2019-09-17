resource "aws_ecs_cluster" "main" {
    name = "cluster"
}

resource "aws_ecs_task_definition" "docker_app" {
    family = "docker_app"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn = "${aws_iam_role.ecs_task_execution_role.arn}"
    network_mode = "awsvpc"
    cpu = "${var.fargate_cpu}"
    memory = "${var.fargate_memory}"
    container_definitions = <<DEFINITION
    [
        {
            "name": "docker_app",
            "image": "${var.app_image}",
            "essential":true,
            "portMappings": [
                {
                    "containerPort":80,
                    "hostPort":80
                }
            ]
        }
    ]
    DEFINITION
}

resource "aws_ecs_service" "main" {
    name = "docker_app_service"
    cluster = "${aws_ecs_cluster.main.id}"
    task_definition = "${aws_ecs_task_definition.docker_app.arn}"
    desired_count = "${var.app_count}"
    launch_type = "FARGATE"

    network_configuration {
        security_groups = ["${aws_security_group.ecs_tasks.id}"]
        subnets = "${aws_subnet.private.*.id}"
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = "${aws_alb_target_group.app.id}"
        container_name = "docker_app"
        container_port = "${var.app_port}"
    }

    #service_registries {
    #   registry_arn = "${aws_service_discovery_service.sd_service.arn}"
    #}

    depends_on = ["aws_alb_listener.front_end"]
}
###############
# Redis Service
###############

resource "aws_ecs_task_definition" "docker_app_redis" {
    family = "docker_redis"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn = "${aws_iam_role.ecs_task_execution_role.arn}"
    network_mode = "awsvpc"
    cpu = "${var.fargate_cpu}"
    memory = "${var.fargate_memory}"
    container_definitions = <<DEFINITION
    [
        {
            "name": "docker_app_redis",
            "image": "redis",
            "essential":true,
            "portMappings": [
                {
                    "containerPort":1000,
                    "hostPort":1000
                }
            ]
        }
    ]
    DEFINITION
}

resource "aws_ecs_service" "redis_service" {
    name = "docker_app_redis_service"
    cluster = "${aws_ecs_cluster.main.id}"
    task_definition = "${aws_ecs_task_definition.docker_app_redis.arn}"
    desired_count = "${var.redis_count}"
    launch_type = "FARGATE"

    network_configuration {
        security_groups = ["${aws_security_group.redis_task.id}"]
        subnets = "${aws_subnet.private.*.id}"
        assign_public_ip = true
    }

    service_registries {
        registry_arn = "${aws_service_discovery_service.sd_service.arn}"
    }


}

########################
# Service Discovery
########################

resource "aws_service_discovery_private_dns_namespace" "sd_dns_namespace" {
    name = "sd_dns_namespace.terraform.local"
    description = "sd_dns_namespace"
    vpc = "${aws_vpc.main.id}"
}

#dns_config: contains information about the resource record sets that you want Route 53 to create when you register an instance
resource "aws_service_discovery_service" "sd_service" {
    name = "sd_service"

    dns_config {
        namespace_id = "${aws_service_discovery_private_dns_namespace.sd_dns_namespace.id}"

        #array with one DnsRecord for each resource record set
        dns_records {
            ttl = 10 #time in seconds that you want DNS resolvers to cache the settings for this resource record set
            type = "A" #type of resource which indiciates the value r53 returns in response to DNS queries (A,AAAA,SRV,CNAME)
        }

        #multivalue or weighted, apply to all records that Route 53 creates when you register an instance and specify the service
        routing_policy = "MULTIVALUE"
    }

    health_check_custom_config {
        failure_threshold = 1
    }
}
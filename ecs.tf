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

    depends_on = ["aws_alb_listener.front_end"]

}

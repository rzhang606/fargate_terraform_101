
#ALB Security
resource "aws_security_group" "lb" {
    name = "load-balancer-sg"
    description = "controls access to the ALB"
    vpc_id = "${aws_vpc.main.id}"

    ingress {
        protocol = "tcp"
        from_port = "${var.app_port}"
        to_port = "${var.app_port}"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#traffic to ecs cluster should only come from ALB
resource "aws_security_group" "ecs_tasks" {
    name = "ecs-tasks-sg"
    description = "allow inbound access from the ALB only"
    vpc_id = "${aws_vpc.main.id}"

    ingress{
        protocol = "tcp"
        from_port = "${var.app_port}"
        to_port = "${var.app_port}"
        security_groups = ["${aws_security_group.lb.id}"]
    }

    #allow outbound anywhere
    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#security group for redis (inbounded from our main web app)
resource "aws_security_group" "redis_task" {
    name="redis-task-sg"
    description = "allow inbound access from the main web app to access redis"
    vpc_id = "${aws_vpc.main.id}"

    #only take inbound from ecs_tasks
    ingress {
        protocol = "tcp"
        from_port = "${var.redis_port}"
        to_port = "${var.redis_port}"
        security_groups = ["${aws_security_group.ecs_tasks.id}"]
    }

    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}
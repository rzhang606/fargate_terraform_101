
variable "aws_region" {
    description = "Main AWS Region"
    default = "us-east-2"
}

variable "ecs_task_execution_role_name" {
    description = "ECS task execution role name"
    default = "myEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
    description = "ECS auto scale role name"
    default = "myEcsAutoScaleRole"
}

variable "az_count" {
    description = "Number of AZs to cover in a given region"
    default = "2"
}

variable "app_image" {
    description = "The docker image to run in ECS cluster"
    default = "rzhang606/friendlyhello:redis"
}

variable "redis_port" {
    description = "port where redis lives"
    default = "6379"
}

variable "app_port" {
    description = "Port exposed by docker to redirect traffic to"
    default = 80
}

variable "app_count" {
    description = "NUmber of docker containers to run"
    default = 1
}

variable "redis_count" {
    description = "Number of redis tasks to run"
    default = 2
}

variable "health_check_path" {
    default = "/"
}

variable "fargate_cpu" {
    description = "Fargate instance CPU units to provision (1vCPU = 1024 units)"
    default = "1024"
}

variable  "fargate_memory" {
    description = "Fargate instance memory to provision (in MiB)"
    default = "2048"
}
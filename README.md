# Using Terraform and Fargate to launch Docker Images

Introduction set up for a cluster by using AWS Fargate for a Docker Image Repo

ECS
- Establish the cluster resource
- Create a task definition
- Define the ecs service resource with the network configuration and load balancer

Network
- data source for availabiliy zones
- vpc resource with cidr address
- create private and public subnets (for each availability zone)
- establish the internet gateway and NAT gateway with elastic IP, and route table + association

Application Load Balancer (ALB)
- load balancer resource with the subnet and security groups
- target group (optional health check declaration)
- alb listener (dependency of ecs service)

Security
-create a security group for each the load balancer and the ecs tasks
-ecs tasks group should only allow inbound access from the ALB

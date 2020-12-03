
provider "aws" {
  access_key = "PUT_YOUR_ACCESS_KEY__HERE"
  secret_key = "PUT_YOUR_ACCESS_SECRET_KEY__HERE"
  region     = "us-east-2"
}
data "aws_availability_zones" "all" {}
### creando EC2 instance
resource "aws_instance" "web" {
  ami               = "${lookup(var.amis,var.region)}"
  count             = "${var.conta}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  source_dest_check = false
  instance_type = "t2.micro"
  # tags {
  #   Name = "${format("web-%03d", count.index + 1)}"
  # }
}
### Creando la seguridad de Grupo para EC2
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
## Creando Launch Configuration
resource "aws_launch_configuration" "example" {
  image_id               = "${lookup(var.amis,var.region)}"
  instance_type          = "t2.micro"
  security_groups        = ["${aws_security_group.instance.id}"]
  key_name               = "${var.key_name}"
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello Terraform from Cloud Computing" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}
## Creating AutoScaling Group
resource "aws_autoscaling_group" "example" {
  name = "terraform-asg-example"
  launch_configuration = "${aws_launch_configuration.example.id}"
  # availability_zones = ["${data.aws_availability_zones.all.names}"]
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
  min_size = 1
  desired_capacity = 2
  max_size = 3
  load_balancers = ["${aws_elb.example.name}"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}
## Security Group para ELB
resource "aws_security_group" "elb" {
  name = "terraform-example-elb"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
### Creando ELB
resource "aws_elb" "example" {
  name = "terraform-elb-example"
  security_groups = ["${aws_security_group.elb.id}"]
  # availability_zones = ["${data.aws_availability_zones.all.names}"]
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "8080"
    instance_protocol = "http"
  }
}

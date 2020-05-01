resource "aws_security_group" "lb-logstash" {
  name = "${upper("sg-lb-logstash")}"
  vpc_id = "${data.aws_vpc.vpc.id}"

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 5044
        to_port = 5044
        protocol = "tcp"
        cidr_blocks  = "${var.public-ips-ingress}"
    }

      tags = {
        Name = "${upper("sg-lb-logstash")}"
      }
}

output lb-logstash {
  value = "${aws_security_group.lb-logstash.id}"
  }


variable "app_count" {
  type    = number
  default = 1
}

variable "region" {
  default = "eu-west-2"
}

variable "cidr_block" {
  default = "10.32.0.0/16"
}

variable "open_cidr" {
  default = "0.0.0.0/0"
}

variable "http_port" {
  default = 80
}

variable "max_capacity" {
  default = 2
}

variable "cooldown" {
  default = 60
}

variable "protocol" {
  default = "-1"
}

variable "retention_in_days" {
  default = 30
}

variable "cpu" {
  default = 1024
}

variable "memory" {
  default = 2048
}


variable "vers" {
  default = "2012-10-17"
}



variable "default_egress_route" {
  type    = string
  default = "0.0.0.0/0"
}

variable "cluster_name" {
  type    = string
  default = "HUBVPC"
}

variable "instance" {
  type = string
  default = "auto"
}

data "alicloud_zones" "default" {
available_instance_type = var.instance != "auto" ? var.instance : coalesce(length(data.alicloud_zones.default_hfc6.zones) >1  ? data.alicloud_zones.default_hfc6.available_instance_type : "", length(data.alicloud_zones.default_c5.zones) >1  ? data.alicloud_zones.default_c5.available_instance_type : "", length(data.alicloud_zones.default_hfc5.zones) > 1 ?data.alicloud_zones.default_hfc5.available_instance_type : "", length(data.alicloud_zones.default_sn1ne.zones) >1 ?data.alicloud_zones.default_sn1ne.available_instance_type : "")

}

resource "alicloud_vpc" "vpc" {
  cidr_block = var.hubvpc_vpc_cidr
  vpc_name       = "${var.cluster_name}-${random_string.random_name_post.result}"
}

//Security Group for fortigate instances
resource "alicloud_security_group" "SecGroup" {
  name        = "${var.cluster_name}-SecGroup-${random_string.random_name_post.result}"
  description = "New security group"
  vpc_id      = alicloud_vpc.vpc.id
}

//Allow All Ingress for Firewall
resource "alicloud_security_group_rule" "allow_all_tcp_ingress" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.SecGroup.id
  cidr_ip           = "0.0.0.0/0"
}

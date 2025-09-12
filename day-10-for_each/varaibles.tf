variable "allowed_ports" {
  description = "Map of ports to CIDRs"
  type        = map(string)

  default = {
    22   = "102.3.1.0/24"     # SSH
    80   = "0.0.0.0/0"        # HTTP
    443  = "0.0.0.0/0"        # HTTPS
    3306 = "13.233.120.45/32" # MySQL
  }
}

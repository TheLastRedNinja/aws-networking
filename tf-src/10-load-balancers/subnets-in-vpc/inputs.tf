variable "vpc-id" {
  type = string
}

variable "default-tags" {
  type    = map(string)
  default = {}
}

variable "resource-specific-tags" {
  description = "Map containing additional tags to be applied for each resource type. Key = aws resource type (terraform resource)"
  type        = map(map(string))
  default     = {}
}

variable "subnet-specs" {
  type = object({
    subnet-name     = string
    subnet-type     = string      # private/public/external(only nat gateway)
    number-of-azs   = number      # number of azs to create a subnet in. null => use all zones in var.availability-zones-in-use
    cidr-prefix     = string      # cidr prefix for all subnets
    cidr-newbits    = number      # number of bits to extend the netmask in each subnet
    additional-tags = map(string) # additional subnet specific tags
  })
}

variable "availability-zones-in-use" {
  type        = list(string)
  description = "The availability zones in use in the region. Determines the number of subnets created"
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "create-nat-gateway" {
  type    = bool
  default = false
}

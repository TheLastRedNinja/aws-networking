variable "vpc-name" {
  type = string
}

variable "vpc-cidr" {
  type    = string
  default = "10.0.0.0/8"
}

variable "azs" {
  type = list(string)
}

variable "create-igw" {
  type    = bool
  default = false
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

variable "subnets" {
  description = "specs of subnets to be created"
  type = map(object({
    subnet-name     = string
    subnet-type     = string      # private/public etc
    number-of-azs   = number      # number of azs to create a subnet in. null => use all zones in var.availability-zones-in-use
    cidr-prefix     = string      # cidr prefix for all subnets
    cidr-newbits    = number      # number of bits to extend the netmask in each subnet
    additional-tags = map(string) # additional subnet specific tags
  }))
}

variable "name-for-default-public-subnet" {
  type        = string
  description = "Name for the public subnet used for placement of internet gateways and load balancers"
  default     = "public"
}
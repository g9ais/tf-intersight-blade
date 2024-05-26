variable "api_key" {
    type    = string
    description = "apikey"
    default = "someapi_key"
}

variable "secretkey" {
    type = string
    description = "Secretkey location"
    default = "somekey.pem" 
}

variable "endpoint" {
    type = string
    description = "api endpoint url"
    default = "https://www.intersight.com"
}

variable "organization" {
    type = string
    description = "organisation moid"
    default = "31415"
}

variable "prefix" {
    type = string
    description = "policies prefix"
    default = "tf-"
}

variable "intersight_tag" {
    type= map
    description = "value"
    default = {
        key = "createdby"
        value = "g9ais"
    }
}

variable "servername" {
    type = string
    description = "server name to be deployed"
    default = "server000"
}

variable "fcconnectivity" {
    type = bool
    description = "either has fc adapters or not!"
    default = false
}

variable "fcWWPNpoolA" {
    type = string
    description = "fcpool WWPN - A identifier - 20:00:00:25:B5:xx:xx:xx"
    default = "20:00:00:25:B5:A0:00:00"
}

variable "fcWWPNpoolB" {
    type = string
    description = "fcpool WWPN - B identifier - 20:00:00:25:B5:xx:xx:xx"
    default = "20:00:00:25:B5:B0:00:00"
}

variable "fcWWNNpool" {
    type = string
    description = "fcpool WWNN identifier - 20:00:00:25:B5:xx:xx:xx"
    default = "20:00:00:25:B5:F0:00:00"
}

variable "fcpool_size" {
    type = number
    description = "fcpool size"
    default = 128
}


variable "macpool_A" {
    type = string
    description = "macpool MAC identifier - 00:25:B5:xx:xx:xx"
    default = "00:25:B5:A0:00:00"
}

variable "macpool_B" {
    type = string
    description = "macpool MAC identifier - 00:25:B5:xx:xx:xx"
    default = "00:25:B5:B0:00:00"
}

variable "macpool_size" {
    type = number
    description = "fcpool size"
    default = 128
}

variable "vlan_allowed_eth0_eth1" {
    type = string
    description = "vlans allowed in eth0 and eth1"
    default = "2-300,1600,1700"
}
variable "native_vlan_eth0_eth1" {
    type = string
    description = "vlans allowed in eth0 and eth1"
    default = "2"
}

variable "vlan_allowed_eth2_eth3" {
    type = string
    description = "vlans allowed in eth0 and eth1"
    default = "2-300,1600,1700"
}
variable "native_vlan_eth2_eth3" {
    type = string
    description = "vlans allowed in eth0 and eth1"
    default = "2"
}

variable "vsan_id_A" {
    type = number
    description = "VSAN_ID Fabric A"
    default = 100
}

variable "vsan_id_B" {
    type = number
    description = "VSAN_ID Fabric B"
    default = 200
}


variable "ip_pool_inband_map" {
    type = map(string)
    default = {
        gateway     = "1.1.1.1"
        netmask     = "255.255.255.254"
        primary_dns = "8.8.8.8"
        ipv4_block = "1.1.1.10"
        size = 130
        vlan = 1700
    }
}
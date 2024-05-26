terraform {
  required_providers {
    intersight = {
      source = "CiscoDevNet/intersight"
      version = ">1.0.27"
    }
  }
}

//init of intersight provider in provider.tf
//something fishy


resource "intersight_ntp_policy" "ntp1" {
  name        = "${var.prefix}-ntp"
  description = "test policy"
  enabled     = true
  timezone = "Europe/Zurich"
  ntp_servers = [
    "ntp.esl.cisco.com",
    "time-a-g.nist.gov",
    "time-b-g.nist.gov"
  ]
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  tags = [
      {
          additional_properties = "",
          key = var.intersight_tag.key,
          value = var.intersight_tag.value
      }
  ]
}

# data "intersight_ntp_policy" "ntp1" {
#     name = "${var.prefix}-ntp"
# }

# output "intersight_ntp_policy_Ct" {
#     description = "output creation time ntp policy"
#     value = [
#         for ntppol in data.intersight_ntp_policy.ntp1.results:
#             "${ntppol.name} -> ${ntppol.create_time}"
#     ]
        
# }

resource "intersight_bios_policy" "biospol1" {
  name        = "${var.prefix}-biospol.def"
  description = "bios policy"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_boot_precision_policy" "bootpol1" {
  name                     = "${var.prefix}-bootpol.kvm_m2raid_fmezz"
  description              = "test policy kvm then m.2 raid then FMEZZ raid"
  configured_boot_mode     = "Uefi"
  enforce_uefi_secure_boot = false
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  boot_devices {
    enabled     = true
    name        = "kvm"
    object_type = "boot.VirtualMedia"
    additional_properties = jsonencode({
      Subtype = "kvm-mapped-dvd"
    })
  }
  boot_devices {
    enabled     = true
    name        = "MRAID"
    object_type = "boot.LocalDisk"
    additional_properties = jsonencode({
      Slot = "MRAID"
      Bootloader = {
        Description = ""
        Name        = ""
        ObjectType  = "boot.Bootloader"
        Path        = ""
      }
    })
  }
  boot_devices {
    enabled     = true
    name        = "FMEZZ"
    object_type = "boot.LocalDisk"
    additional_properties = jsonencode({
      Slot = "FMEZZ1-SAS"
      Bootloader = {
        Description = ""
        Name        = ""
        ObjectType  = "boot.Bootloader"
        Path        = ""
      }
    })
  }
}

resource "intersight_power_policy" "srv_powerpol" {
  name             = "${var.prefix}-powerpolicy"
  description      = "powerpolicy default. note many items apply to UCS-X only"
  power_restore_state = "LastState"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_ippool_pool" "ippool_inband1" {
  name             = "${var.prefix}-imc_ip_pool_inband"
  description      = "inband IP Pool for IMC access"
  assignment_order = "sequential"
  ip_v4_config {
    object_type = "ippool.IpV4Config"
    gateway     = var.ip_pool_inband_map["gateway"]
    netmask     = var.ip_pool_inband_map["netmask"]
    primary_dns = var.ip_pool_inband_map["primary_dns"]
  }
  ip_v4_blocks {
    object_type = "ippool.IpV4Block"
    from = var.ip_pool_inband_map["ipv4_block"]
    size = var.ip_pool_inband_map["size"]
  }
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

#This might need a revisit - Intersight does not like updating uuid pool even if in place.
resource "intersight_uuidpool_pool" "uuidpool_pool1" {
  name             = "${var.prefix}-uuid_pool"
  description      = "uuidpool"
  assignment_order = "sequential"
  prefix           = "c15c04c5-0000-0000"
  uuid_suffix_blocks {
    class_id    = "uuidpool.UuidBlock"
    object_type = "uuidpool.UuidBlock"
    from        = "cafe-012300000001"
    to          = "cafe-0123000000ff"
  }
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}


resource "intersight_fcpool_pool" "fcwwpn_A" {
  name             = "${var.prefix}-fcwwpn_A"
  description      = "fcpool pool"
  assignment_order = "sequential"
 
  id_blocks = [{
    object_type = "fcpool.Block"
    from        = var.fcWWPNpoolA
    size = var.fcpool_size
    class_id    = "fcpool.Block"
    additional_properties = "", to = ""
    }]

  pool_purpose = "WWPN"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_fcpool_pool" "fcwwpn_B" {
  name             = "${var.prefix}-fcwwpn_B"
  description      = "fcpool pool"
  assignment_order = "sequential"
  id_blocks {
    object_type = "fcpool.Block"
    from        = var.fcWWPNpoolB
    size = var.fcpool_size
    class_id    = "fcpool.Block"
  }
  pool_purpose = "WWPN"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_fcpool_pool" "fcwwnn" {
  name             = "${var.prefix}-fcwwnn"
  description      = "fcpool pool"
  assignment_order = "sequential"
  id_blocks {
    object_type = "fcpool.Block"
    from        = var.fcWWNNpool
    size = var.fcpool_size
    class_id    = "fcpool.Block"
  }
  pool_purpose = "WWNN"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_macpool_pool" "macpool_A" {
  name = "${var.prefix}-macpool_A"

  mac_blocks {
    from = var.macpool_A
    size = var.macpool_size
  }
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_macpool_pool" "macpool_B" {
  name = "${var.prefix}-macpool_B"

  mac_blocks {
    from = var.macpool_B
    size = var.macpool_size
  }
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}


/* Device Connector only for standalone, no need for blade
resource "intersight_deviceconnector_policy" "dc_pol1" {
  name            = "${var.prefix}-dc_lockout.off"
  description     = "device connector policy"
  lockout_enabled = false
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  
}
*/

resource "intersight_vmedia_policy" "vmedia1" {
  name          = "${var.prefix}-vmedia.def"
  description   = "vmedia policy"
  enabled       = true
  encryption    = true
  low_power_usb = true
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_kvm_policy" "kvm1" {
  name                      = "${var.prefix}-kvm.def"
  description               = "kvm policy"
  enabled                   = true
  maximum_sessions          = 3
  remote_port               = 2069
  enable_video_encryption   = true
  enable_local_server_video = true
  tunneled_kvm_enabled      = true
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_access_policy" "imc_access_srv1" {
  name        = "${var.prefix}-access_imc"
  description = "imc Accesspolicy"
  inband_vlan = var.ip_pool_inband_map["vlan"]
  inband_ip_pool {
    object_type = "ippool.Pool"
    moid        = intersight_ippool_pool.ippool_inband1.moid
  }
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

#---------ETH0-4 and POLICIES DEF------------------

/* only for standalone 
resource "intersight_vnic_eth_network_policy" "ethnetpol_trunk" {
  name = "${var.prefix}-eth_trunk.nat2"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  vlan_settings {
    object_type  = "vnic.VlanSettings"
    default_vlan = 2
    mode         = "TRUNK"
  }
}
*/
resource "intersight_fabric_eth_network_group_policy" "fabric_eth_network_group_policy_eth0_1" {
  name        = "${var.prefix}-vlans_eth0_1"
  description = "vlans allowed in eth0 eth1 adapters"
  vlan_settings {
    native_vlan   = var.native_vlan_eth0_eth1
    allowed_vlans = var.vlan_allowed_eth0_eth1
    object_type   = "fabric.VlanSettings"
  }
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_fabric_eth_network_group_policy" "fabric_eth_network_group_policy_eth2_3" {
  name        = "${var.prefix}-vlans_eth2_3"
  description = "vlans allowed in eth2 eth3 adapters"
  vlan_settings {
    native_vlan   = var.native_vlan_eth2_eth3
    allowed_vlans = var.vlan_allowed_eth2_eth3
    object_type   = "fabric.VlanSettings"
  }
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}



resource "intersight_fabric_eth_network_control_policy" "fabric_eth_network_control_policy1" {
  name        = "${var.prefix}-ncp_lldp.on_cdp.on_lstrack.dis_macforge.allow"
  description = "cdp on, lldp on, uplink failover disable"
  cdp_enabled = true
  forge_mac   = "allow"
  lldp_settings {
    class_id         = "fabric.LldpSettings"
    object_type      = "fabric.LldpSettings"
    receive_enabled  = true
    transmit_enabled = true
  }
  mac_registration_mode = "allVlans"
  uplink_fail_action    = "linkDown"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_vnic_eth_qos_policy" "ethqospol_trust" {
  name           = "${var.prefix}-qos.trust"
  description    = "demo vnic eth qos policy"
  mtu            = 1500
  rate_limit     = 0
  cos            = 0
  burst          = 10240
  priority       = "Best Effort"
  trust_host_cos = true
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_vnic_eth_adapter_policy" "ethadptpol_vmware" {
  name                    = "${var.prefix}-ethadapter.vmware"
  rss_settings            = false
  uplink_failback_timeout = 5
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  vxlan_settings {
    enabled = false
  }

  nvgre_settings {
    enabled = false
  }

  arfs_settings {
    enabled = false
  }

  interrupt_settings {
    coalescing_time = 125
    coalescing_type = "MIN"
    nr_count        = 4
    mode            = "MSIx"
  }
  completion_queue_settings {
    nr_count  = 2
    #ring_size = 1
  }
  rx_queue_settings {
    nr_count  = 1
    ring_size = 512
  }
  tx_queue_settings {
    nr_count  = 1
    ring_size = 256
  }
  tcp_offload_settings {
    large_receive = true
    large_send    = true
    rx_checksum   = true
    tx_checksum   = true
  }
}



# see if can iterate this on amount of nics + trunks. note placement


resource "intersight_vnic_eth_if" "eth0" {
  name  = "eth0"
  order = 0
  mac_address_type = "POOL"
  mac_pool = [ {
    moid = intersight_macpool_pool.macpool_A.moid
    object_type = "macpool.Pool"
    additional_properties = ""
    class_id = ""
    selector = ""
  } ]
  placement {
    /*id       = "MLOM"
    pci_link = 0
    uplink   = 0
    */
    auto_pci_link = true
    auto_slot_id = true
    switch_id = "A"
  }
  # cdn {
  #   value     = "VIC-1-eth00"
  #   nr_source = "user"
  # }
  # usnic_settings {
  #   cos      = 5
  #   nr_count = 0
  # }
  vmq_settings {
    enabled             = false
    multi_queue_support = false
    num_interrupts      = 1
    num_vmqs            = 1
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.vniclancon1.moid
    object_type = "vnic.LanConnectivityPolicy"
  }
  fabric_eth_network_control_policy {
    moid = intersight_fabric_eth_network_control_policy.fabric_eth_network_control_policy1.moid
  }
  fabric_eth_network_group_policy {
    moid = intersight_fabric_eth_network_group_policy.fabric_eth_network_group_policy_eth0_1.moid
  }
  /*eth_network_policy {
    moid = intersight_vnic_eth_network_policy.ethnetpol_trunk.moid
  }*/
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.ethadptpol_vmware.moid
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.ethqospol_trust.moid
  }
}


resource "intersight_vnic_eth_if" "eth1" {
  name  = "eth1"
  order = 1
  mac_address_type = "POOL"
  mac_pool = [ {
    moid = intersight_macpool_pool.macpool_B.moid
    object_type = "macpool.Pool"
    additional_properties = ""
    class_id = ""
    selector = ""
  } ]
  placement {
    /*id       = "MLOM"
    pci_link = 0
    uplink   = 0
    */
    auto_pci_link = true
    auto_slot_id = true
    switch_id = "B"
  }
  # cdn {
  #   value     = "VIC-1-eth00"
  #   nr_source = "user"
  # }
  # usnic_settings {
  #   cos      = 5
  #   nr_count = 0
  # }
  vmq_settings {
    enabled             = false
    multi_queue_support = false
    num_interrupts      = 1
    num_vmqs            = 1
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.vniclancon1.moid
    object_type = "vnic.LanConnectivityPolicy"
  }
  fabric_eth_network_control_policy {
    moid = intersight_fabric_eth_network_control_policy.fabric_eth_network_control_policy1.moid
  }
  fabric_eth_network_group_policy {
    moid = intersight_fabric_eth_network_group_policy.fabric_eth_network_group_policy_eth0_1.moid
  }
  /*eth_network_policy {
    moid = intersight_vnic_eth_network_policy.ethnetpol_trunk.moid
  }*/
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.ethadptpol_vmware.moid
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.ethqospol_trust.moid
  }
}


resource "intersight_vnic_eth_if" "eth2" {
  name  = "eth2"
  order = 2
  mac_address_type = "POOL"
  mac_pool = [ {
    moid = intersight_macpool_pool.macpool_A.moid
    object_type = "macpool.Pool"
    additional_properties = ""
    class_id = ""
    selector = ""
  } ]
  placement {
    /*id       = "MLOM"
    pci_link = 0
    uplink   = 0
    */
    auto_pci_link = true
    auto_slot_id = true
    switch_id = "A"
  }
  # cdn {
  #   value     = "VIC-1-eth00"
  #   nr_source = "user"
  # }
  # usnic_settings {
  #   cos      = 5
  #   nr_count = 0
  # }
  vmq_settings {
    enabled             = false
    multi_queue_support = false
    num_interrupts      = 1
    num_vmqs            = 1
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.vniclancon1.moid
    object_type = "vnic.LanConnectivityPolicy"
  }
  fabric_eth_network_control_policy {
    moid = intersight_fabric_eth_network_control_policy.fabric_eth_network_control_policy1.moid
  }
  fabric_eth_network_group_policy {
    moid = intersight_fabric_eth_network_group_policy.fabric_eth_network_group_policy_eth2_3.moid
  }
  /*eth_network_policy {
    moid = intersight_vnic_eth_network_policy.ethnetpol_trunk.moid
  }*/
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.ethadptpol_vmware.moid
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.ethqospol_trust.moid
  }
}


resource "intersight_vnic_eth_if" "eth3" {
  name  = "eth3"
  order = 3
  mac_address_type = "POOL"
  mac_pool = [ {
    moid = intersight_macpool_pool.macpool_B.moid
    object_type = "macpool.Pool"
    additional_properties = ""
    class_id = ""
    selector = ""
  } ]
  placement {
    /*id       = "MLOM"
    pci_link = 0
    uplink   = 0
    */
    auto_pci_link = true
    auto_slot_id = true
    switch_id = "B"
  }
  # cdn {
  #   value     = "VIC-1-eth00"
  #   nr_source = "user"
  # }
  # usnic_settings {
  #   cos      = 5
  #   nr_count = 0
  # }
  vmq_settings {
    enabled             = false
    multi_queue_support = false
    num_interrupts      = 1
    num_vmqs            = 1
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.vniclancon1.moid
    object_type = "vnic.LanConnectivityPolicy"
  }
  fabric_eth_network_control_policy {
    moid = intersight_fabric_eth_network_control_policy.fabric_eth_network_control_policy1.moid
  }
  fabric_eth_network_group_policy {
    moid = intersight_fabric_eth_network_group_policy.fabric_eth_network_group_policy_eth2_3.moid
  }
  /*eth_network_policy {
    moid = intersight_vnic_eth_network_policy.ethnetpol_trunk.moid
  }*/
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.ethadptpol_vmware.moid
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.ethqospol_trust.moid
  }
}


resource "intersight_vnic_lan_connectivity_policy" "vniclancon1" {
  name                = "${var.prefix}-fi_lan_4nic"
  description         = "vnic lan connectivity policy for FI attached servers"
  iqn_allocation_type = "None"
  placement_mode      = "auto"
  target_platform     = "FIAttached"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  # not needed to add eth_if's as eth_if ask to be bound to a lan conn policy
  # eth_ifs {
  #   object_type = "vnic.EthIf"
  #   moid        = intersight_vnic_eth_if.eth0.moid
  # }

}


#---------hba0-1 and POLICIES DEF------------------
# add this into var if needed
resource "intersight_vnic_fc_network_policy" "fc_netvsan_A" {
  count = var.fcconnectivity ? 1 : 0
  name = "${var.prefix}-fc_vsan.A"
  vsan_settings {
    id = var.vsan_id_A
    default_vlan_id = var.vsan_id_A
  }
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}
resource "intersight_vnic_fc_network_policy" "fc_netvsan_B" {
  count = var.fcconnectivity ? 1 : 0
  name = "${var.prefix}-fc_vsan.B"
  vsan_settings {
    id = var.vsan_id_B
    default_vlan_id = var.vsan_id_B
  }
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_vnic_fc_adapter_policy" "fc_adaptpol_vmware" {
  count = var.fcconnectivity ? 1 : 0
  name                    = "${var.prefix}-fcadapter.vmware"
  error_detection_timeout = 100000
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  error_recovery_settings {
    enabled           = false
    io_retry_count    = 255
    io_retry_timeout  = 5
    link_down_timeout = 30000
    port_down_timeout = 10000
  }

  flogi_settings {
    retries = 8
    timeout = 4000
  }

  interrupt_settings {
    mode = "MSIx"
  }

  io_throttle_count = 256
  lun_count         = 1024
  lun_queue_depth   = 20

  plogi_settings {
    retries = 8
    timeout = 20000
  }
  resource_allocation_timeout = 10000

  rx_queue_settings {
    #nr_count  = 1
    ring_size = 64
  }
  tx_queue_settings {
    #nr_count  = 1
    ring_size = 64
  }


  scsi_queue_settings {
    nr_count  = 1
    ring_size = 512
  }

}

resource "intersight_vnic_fc_qos_policy" "fcqospol_def" {
  count = var.fcconnectivity ? 1 : 0
  name           = "${var.prefix}-fcqos.def"
  description    = "demo vhba qos policy"
  rate_limit          = 0
  cos                 = 3
  max_data_field_size = 2112
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_vnic_fc_if" "fc0" {
  count = var.fcconnectivity ? 1 : 0
  name  = "fc0"
  order = 4
  placement {
    /*id       = "MLOM"
    pci_link = 0
    uplink   = 0
    */
    auto_pci_link = true
    auto_slot_id = true
    switch_id = "A"
  }
  wwpn_address_type = "POOL"
  wwpn_pool = [ {
    moid = intersight_fcpool_pool.fcwwpn_A.moid
    object_type = "fcpool.Pool"
    additional_properties = ""
    class_id = ""
    selector = ""
  } ]

  persistent_bindings = true
  san_connectivity_policy {
    moid        = intersight_vnic_san_connectivity_policy.vhbasanconn1[0].moid
    object_type = "vnic.SanConnectivityPolicy"
  }
  fc_network_policy {
    moid = intersight_vnic_fc_network_policy.fc_netvsan_A[0].moid
  }
  fc_adapter_policy {
    moid = intersight_vnic_fc_adapter_policy.fc_adaptpol_vmware[0].moid
  }
  fc_qos_policy {
    moid = intersight_vnic_fc_qos_policy.fcqospol_def[0].moid
  }
}

resource "intersight_vnic_fc_if" "fc1" {
  count = var.fcconnectivity ? 1 : 0
  name  = "fc1"
  order = 5
  placement {
    /*id       = "MLOM"
    pci_link = 0
    uplink   = 0
    */
    auto_pci_link = true
    auto_slot_id = true
    switch_id = "B"
  }
  wwpn_address_type = "POOL"
  wwpn_pool = [ {
    moid = intersight_fcpool_pool.fcwwpn_B.moid
    object_type = "fcpool.Pool"
    additional_properties = ""
    class_id = ""
    selector = ""
  } ]
  persistent_bindings = true
  san_connectivity_policy {
    moid        = intersight_vnic_san_connectivity_policy.vhbasanconn1[0].moid
    object_type = "vnic.SanConnectivityPolicy"
  }
  fc_network_policy {
    moid = intersight_vnic_fc_network_policy.fc_netvsan_B[0].moid
  }
  fc_adapter_policy {
    moid = intersight_vnic_fc_adapter_policy.fc_adaptpol_vmware[0].moid
  }
  fc_qos_policy {
    moid = intersight_vnic_fc_qos_policy.fcqospol_def[0].moid
  }
}


resource "intersight_vnic_san_connectivity_policy" "vhbasanconn1" {
  count = var.fcconnectivity ? 1 : 0
  name              = "${var.prefix}-san_2hba"
  description       = "vhba for server (fcoe based)"
  placement_mode    = "auto"
  target_platform   = "FIAttached"
  wwnn_address_type = "POOL"
  wwnn_pool = [ {
    moid = intersight_fcpool_pool.fcwwnn.moid
    object_type = "fcpool.Pool"
    additional_properties = ""
    class_id = ""
    selector = ""
  } ]
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}


# Adapter config 
/* only for standalone
resource "intersight_adapter_config_policy" "adaptercfg1" {
  name        = "${var.prefix}-adaptercfg.MLOM"
  description = "test policy"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  settings {
    object_type = "adapter.AdapterConfig"
    slot_id     = "MLOM"
    eth_settings {
      lldp_enabled = true
      object_type  = "adapter.EthSettings"
    }
    fc_settings {
      object_type = "adapter.FcSettings"
      fip_enabled = false
    }
    port_channel_settings {
      enabled = false
      object_type = "adapter.PortChannelSettings"
    }
  }
  # profiles {
  #   moid        = server.moid
  #   object_type = "server.Profile"
  # }
}
*/




resource "intersight_networkconfig_policy" "netcfg1" { 
  name                     = "${var.prefix}-netcfg.dns.google"
  description              = "network configuration policy"
  enable_dynamic_dns       = false
  preferred_ipv6dns_server = "::"
  enable_ipv6              = false
  enable_ipv6dns_from_dhcp = false
  preferred_ipv4dns_server = "8.8.8.8"
  alternate_ipv4dns_server = "8.8.4.4"
  alternate_ipv6dns_server = "::"
  dynamic_dns_domain       = ""
  enable_ipv4dns_from_dhcp = false
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

#This will handle SSD's in FMEZZ Controller  policy creation (not part of SP created)
resource "intersight_storage_drive_group" "fmezz_raid_group1" {
  #(RO) type       = 0
  name       = "FMEZZ_RAID1"
  raid_level = "Raid1"
  manual_drive_group {
    span_groups {
      slots = "1-2"
    }
  }
  virtual_drives {
    name                = "VDBoot"
    size                = 0
    expand_to_available = true
    boot_drive          = true
    virtual_drive_policy {
      strip_size    = 64
      write_policy  = "Default"
      read_policy   = "Default"
      access_policy = "Default"
      drive_cache   = "Default"
      object_type   = "storage.VirtualDrivePolicy"
    }
  }
  storage_policy {
     moid = intersight_storage_storage_policy.storpol2.moid
  }
}

resource "intersight_storage_storage_policy" "storpol2" {
  name                     = "${var.prefix}-storpolicy.FMEZZ_RAID1"
  use_jbod_for_vd_creation = false
  description              = "storage policy SSD in raid 1 for boot"
  unused_disks_state       = "NoChange"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  global_hot_spares = ""
  #m2_virtual_drive {
  #  enable      = true
  #  controller_slot = "MSTOR-RAID-1"
  #  object_type = "storage.M2VirtualDriveConfig"
  #}
  #drive_group [ {
  #   moid = intersight_storage_drive_group.fmezz_raid_group1.moid
  #   object_type = "storage.DriveGroup"
  #} ]
  # always indicate on child which is its parent, not that a parent has a child!!!.
}

resource "intersight_storage_storage_policy" "storpol1" {
  name                     = "${var.prefix}-storpolicy.M2_RAID1"
  use_jbod_for_vd_creation = false
  description              = "storage policy M2 in raid 1 for boot"
  unused_disks_state       = "NoChange"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  global_hot_spares = ""
  m2_virtual_drive {
    enable      = true
    controller_slot = "MSTOR-RAID-1"
    object_type = "storage.M2VirtualDriveConfig"
  }
  # drive_group {
  #   moid = intersight_storage_drive_group.raid_group1.moid
  #   object_type = "storage.DriveGroup"
  # }
  # always indicate on child which is its parent, not that a parent has a child.
}





#--------------------------M6 Server---------------------------------

resource "intersight_server_profile" "serverm6" {
  name   = "${var.servername}-m6"
  description = "server profile deployed through terraform"
  action = "No-op"
  tags = [
      {
          additional_properties = "",
          key = var.intersight_tag.key,
          value = var.intersight_tag.value
      }
  ]
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  target_platform = "FIAttached"
  server_assignment_mode = "None"
  uuid_address_type = "POOL"
  uuid_pool = [ {
    moid = intersight_uuidpool_pool.uuidpool_pool1.moid
    object_type = "uuidpool.Pool"
    additional_properties = ""
    class_id = ""
    selector = ""
  } ]

  policy_bucket = concat ([
   {
     moid = intersight_ntp_policy.ntp1.moid,
     object_type           = "ntp.Policy",
     class_id              = "ntp.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_power_policy.srv_powerpol.moid,
     object_type           = "power.Policy",
     class_id              = "power.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_access_policy.imc_access_srv1.moid,
     object_type           = "access.Policy",
     class_id              = "access.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_bios_policy.biospol1.moid,
     object_type           = "bios.Policy",
     class_id              = "bios.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_boot_precision_policy.bootpol1.moid,
     object_type           = "boot.PrecisionPolicy",
     class_id              = "boot.PrecisionPolicy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_vmedia_policy.vmedia1.moid,
     object_type           = "vmedia.Policy",
     class_id              = "vmedia.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_kvm_policy.kvm1.moid
     object_type           = "kvm.Policy",
     class_id              = "kvm.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_vnic_lan_connectivity_policy.vniclancon1.moid,
     object_type           = "vnic.LanConnectivityPolicy",
     class_id              = "vnic.LanConnectivityPolicy",
     additional_properties = "",
     selector              = ""
   },
   
   {
     moid = intersight_storage_storage_policy.storpol1.moid
     object_type           = "storage.StoragePolicy",
     class_id              = "storage.StoragePolicy",
     additional_properties = "",
     selector              = ""
   } 
  ], var.fcconnectivity ? [{
     moid = intersight_vnic_san_connectivity_policy.vhbasanconn1[0].moid
     object_type           = "vnic.SanConnectivityPolicy",
     class_id              = "vnic.SanConnectivityPolicy",
     additional_properties = "",
     selector              = ""
   }]: [])
}



#--------------------------M5 Server---------------------------------

resource "intersight_server_profile" "serverm5" {
  name   = "${var.servername}-m5"
  description = "server profile deployed through terraform"
  action = "No-op"
  tags = [
      {
          additional_properties = "",
          key = var.intersight_tag.key,
          value = var.intersight_tag.value
      }
  ]
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  target_platform = "FIAttached"
  server_assignment_mode = "None"
  uuid_address_type = "POOL"
  uuid_pool = [ {
    moid = intersight_uuidpool_pool.uuidpool_pool1.moid
    object_type = "uuidpool.Pool"
    additional_properties = ""
    class_id = ""
    selector = ""
  } ]

  policy_bucket = concat ([
   {
     moid = intersight_ntp_policy.ntp1.moid,
     object_type           = "ntp.Policy",
     class_id              = "ntp.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_power_policy.srv_powerpol.moid,
     object_type           = "power.Policy",
     class_id              = "power.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_access_policy.imc_access_srv1.moid,
     object_type           = "access.Policy",
     class_id              = "access.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_bios_policy.biospol1.moid,
     object_type           = "bios.Policy",
     class_id              = "bios.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_boot_precision_policy.bootpol1.moid,
     object_type           = "boot.PrecisionPolicy",
     class_id              = "boot.PrecisionPolicy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_vmedia_policy.vmedia1.moid,
     object_type           = "vmedia.Policy",
     class_id              = "vmedia.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_kvm_policy.kvm1.moid
     object_type           = "kvm.Policy",
     class_id              = "kvm.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_vnic_lan_connectivity_policy.vniclancon1.moid,
     object_type           = "vnic.LanConnectivityPolicy",
     class_id              = "vnic.LanConnectivityPolicy",
     additional_properties = "",
     selector              = ""
   },
   
   {
     moid = intersight_storage_storage_policy.storpol2.moid
     object_type           = "storage.StoragePolicy",
     class_id              = "storage.StoragePolicy",
     additional_properties = "",
     selector              = ""
   } 
  ], var.fcconnectivity ? [{
     moid = intersight_vnic_san_connectivity_policy.vhbasanconn1[0].moid
     object_type           = "vnic.SanConnectivityPolicy",
     class_id              = "vnic.SanConnectivityPolicy",
     additional_properties = "",
     selector              = ""
   }]: [])
}


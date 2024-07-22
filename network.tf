resource "oci_core_vcn" "k3s_vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "k3s_vcn"
}

resource "oci_core_subnet" "k3s_subnet" {
  cidr_block        = var.subnet_cidr
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.k3s_vcn.id
  display_name      = "k3s_subnet"
  route_table_id    = oci_core_route_table.k3s_route_table.id
  security_list_ids = [oci_core_security_list.k3s_security_list.id]
}

resource "oci_core_internet_gateway" "k3s_internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "k3s_internet_gateway"
}

resource "oci_core_route_table" "k3s_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "k3s_route_table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.k3s_internet_gateway.id
  }
}

resource "oci_core_security_list" "k3s_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "k3s_security_list"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  # Rule for allowing all traffic within the cluster node subnet
  ingress_security_rules {
    protocol = "all"
    source   = var.subnet_cidr
  }

  # Rule for external SSH access
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }
}
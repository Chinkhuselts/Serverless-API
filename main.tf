# main.tf

# 1. Create a Virtual Cloud Network (VCN)
resource "oci_core_vcn" "serverless_vcn" {
  compartment_id = var.tenancy_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "ibm-portfolio-vcn"
}

# 2. Create an Internet Gateway (The Door)
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.serverless_vcn.id
  display_name   = "ibm-portfolio-igw"
  enabled        = true
}

# 3. Create a Route Table (The Directions)
resource "oci_core_route_table" "public_rt" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.serverless_vcn.id
  display_name   = "ibm-portfolio-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

# 4. Create a Security List (The Bouncer / Firewall)
resource "oci_core_security_list" "public_sl" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.serverless_vcn.id
  display_name   = "ibm-portfolio-sl"

  # Allow all traffic to leave the network
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Allow inbound HTTPS traffic (Port 443)
  ingress_security_rules {
    protocol = "6" # TCP protocol
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }
}

# 5. Create the Subnet (Now attached to the Door and the Firewall)
resource "oci_core_subnet" "serverless_subnet" {
  compartment_id    = var.tenancy_ocid
  vcn_id            = oci_core_vcn.serverless_vcn.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "ibm-portfolio-subnet"
  
  prohibit_public_ip_on_vnic = false 
  
  # Attach the Route Table and Security List we just made!
  route_table_id    = oci_core_route_table.public_rt.id
  security_list_ids = [oci_core_security_list.public_sl.id]
}

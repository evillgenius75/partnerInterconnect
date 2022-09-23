variable "fabric_notification_users" {
  type        = list(string)
  description = "A list of email addresses used for sending connection update notifications."

  validation {
    condition     = length(var.fabric_notification_users) > 0
    error_message = "Notification list cannot be empty."
  }
}

variable "fabric_connection_name" {
  type        = string
  description = "Name of the connection resource that will be created. It will be auto-generated if not specified."
  default     = ""
}

variable "fabric_destination_metro_code" {
  type        = string
  description = <<EOF
  Destination Metro code where the connection will be created. If you do not know the code, 'fabric_destination_metro_name'
  can be use instead.
  EOF
  default     = ""

  validation {
    condition = (
    var.fabric_destination_metro_code == "" ? true : can(regex("^[A-Z]{2}$", var.fabric_destination_metro_code))
    )
    error_message = "Valid metro code consits of two capital leters, i.e. 'FR', 'SV', 'DC'."
  }
}

variable "fabric_destination_metro_name" {
  type        = string
  description = <<EOF
  Only required in the absence of 'fabric_destination_metro_code'. Metro name where the connection will be created,
  i.e. 'Frankfurt', 'Silicon Valley', 'Ashburn'. One of 'fabric_destination_metro_code', 'fabric_destination_metro_name'
  must be provided.
  EOF
  default     = ""
}

variable "network_edge_device_id" {
  type        = string
  description = "Unique identifier of the Network Edge virtual device from which the connection would originate."
  default     = ""
}

variable "network_edge_device_interface_id" {
  type        = number
  description = <<EOF
  Applicable with 'network_edge_device_id', identifier of network interface on a given device, used for a connection.
  If not specified then first available interface will be selected.
  EOF
  default     = 0
}

variable "network_edge_configure_bgp" {
  type        = bool
  description = <<EOF
  Creation and management of Equinix Network Edge BGP peering configurations. Applicable with
  'network_edge_device_id'.
  EOF
  default     = false
}

variable "fabric_port_name" {
  type        = string
  description = <<EOF
  Name of the buyer's port from which the connection would originate. One of 'fabric_port_name',
  'network_edge_device_id' or 'fabric_service_token_id' is required.
  EOF
  default     = ""
}

variable "fabric_vlan_stag" {
  type        = number
  description = <<EOF
  S-Tag/Outer-Tag of the primary connection - a numeric character ranging from 2 - 4094. Required if
  'port_name' is specified.
  EOF
  default     = 0
}

variable "fabric_service_token_id" {
  type        = string
  description = <<EOF
  Unique Equinix Fabric key shared with you by a provider that grants you authorization to use their interconnection
  asset from which the connection would originate.
  EOF
  default     = ""
}

variable "fabric_speed" {
  type        = number
  description = <<EOF
  Speed/Bandwidth in Mbps to be allocated to the connection. If not specified, it will be used the minimum
  bandwidth available for the Google Cloud Partner Interconnect service profile.
  EOF
  default     = 0

  validation {
    condition = contains([0, 50, 100, 200, 300, 400, 500, 1000, 2000, 5000, 10000], var.fabric_speed)
    error_message = "Valid values are (50, 100, 200, 300, 400, 500, 1000, 2000, 5000, 10000)."
  }
}

variable "fabric_purchase_order_number" {
  type        = string
  description = "Connection's purchase order number to reflect on the invoice."
  default     = ""
}

variable "gcp_availability_domain" {
  type = number
  description = <<EOF
  Valid values for are (1, 2). Desired availability domain for the attachment. For improved reliability, customers
  should configure a pair of attachments with one per availability domain. Default is 1.
  EOF
  default = 1

  validation {
    condition = contains([1, 2], var.gcp_availability_domain)
    error_message = "Valid values are (1, 2)."
  }
}

variable "gcp_region" {
  type        = string
  description = <<EOF
  The region in which the GCP resources and the Equinix port for GCP resides, i.e. 'us-west1'. If unspecified, this
  defaults to the region configured in the google provider.
  EOF
  default     = ""
}

variable "gcp_project" {
  type        = string
  description = "The project in which the GCP resources resides. If it is not provided, the provider project is used."
  default     = ""
}

variable "gcp_compute_network_name" {
  type        = string
  description = "The name of an existing Google Cloud VPC network. If unspecified, default regional network will be used."
  default     = "default"
}

variable "gcp_compute_create_router" {
  type        = bool
  description = "Create a Google Cloud router to assign the InterconnectAttachment ."
  default     = true
}

variable "gcp_compute_router_name" {
  type        = string
  description = "The name for Google Cloud router. If unspecified, it will be auto-generated. Required if 'gcp_compute_create_router' is false."
  default     = ""
}

variable "gcp_compute_interconnect_name" {
  type        = string
  description = "The name for Google Cloud InterconnectAttachment. If unspecified, it will be auto-generated."
  default     = ""
}

variable "gcp_interconnect_customer_asn" {
  type        = string
  description = "The autonomous system (AS) number for Border Gateway Protocol (BGP) configuration on customer side."
  default     = "65000"
}

variable "platform" {
  type        = string
  description = <<EOF
  Platform this terraform module will run on. Applicable with 'gcp_configure_bgp' and 'network_edge_configure_bgp'.
  Read 'gcp_configure_bgp' description for further details.
  EOF

  default     = "linux"

  validation {
    condition = contains(["linux", "darwin"], var.platform)
    error_message = "Valid values are (linux, darwin)."
  }
}

variable "gcp_configure_bgp" {
  type        = bool
  description = <<EOF
  To complete configuration of bgp peering in Google platform. If 'network_edge_configure_bgp' is set to 'true',
  then BGP will be configured as well in gcp even if 'gcp_configure_bgp' is set to 'false'.

  NOTE: Configuration of the bgp customer ASN in google side is not directly supported with current google terraform
  provider (v3.72.0). As a workaround this module take advantage of 'terraform-google-gcloud' module which allows use
  gcloud. However, it is only available for `linux` and `darwin` based operating systems.
  EOF
  default     = false
}

variable "gcp_gcloud_skip_download" {
  description = <<EOF
  Whether to skip downloading gcloud (assumes gcloud is already available outside the module). Applicbale with
  'gcp_configure_bgp' and 'network_edge_configure_bgp'. Read 'gcp_configure_bgp' description for further details.
  EOF
  type        = bool
  default     = true
}
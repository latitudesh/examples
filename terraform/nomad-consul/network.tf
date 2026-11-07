// Private network (VLAN) the Nomad/Consul nodes use to talk to each other.
// Its VID is passed to the setup scripts, which add the VLAN interface.
resource "latitudesh_virtual_network" "nomad_vlan" {
  description = "Nomad/Consul private network"
  site        = var.nomad_region
  project     = var.project_id
}

resource "latitudesh_vlan_assignment" "assign_servers" {
  count              = var.nomad_server_count
  server_id          = latitudesh_server.nomad_servers[count.index].id
  virtual_network_id = latitudesh_virtual_network.nomad_vlan.id
}

resource "latitudesh_vlan_assignment" "assign_clients" {
  count              = var.nomad_client_count
  server_id          = latitudesh_server.nomad_clients[count.index].id
  virtual_network_id = latitudesh_virtual_network.nomad_vlan.id
}

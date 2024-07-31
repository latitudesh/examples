resource "latitudesh_virtual_network" "nomad_vlan" {
  description      = "nomad_vlan"
  site             = var.nomad_region
  project          = var.project_id
}

resource "latitudesh_vlan_assignment" "assign_servers" {
  count            = var.nomad_server_count
  server_id = latitudesh_server.nomad_servers.*.id[count.index]
  virtual_network_id = latitudesh_virtual_network.nomad_vlan.id
}

resource "latitudesh_vlan_assignment" "assign_clients" {
  count            = var.nomad_client_count
  server_id = latitudesh_server.nomad_clients.*.id[count.index]
  virtual_network_id = latitudesh_virtual_network.nomad_vlan.id
}

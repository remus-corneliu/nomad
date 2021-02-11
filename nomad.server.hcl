log_level = "DEBUG"

name       = "server1"
region     = "EU-EST"
datacenter = "RO"

data_dir   = "/nomad/data/"

bind_addr = "0.0.0.0"

ports {
  http = 4646
  rpc  = 4647
  serf = 4648
}

advertise {
  http = "{{ GetPrivateIP }}:4646"
  rpc  = "{{ GetPrivateIP }}:4647"
  serf = "{{ GetPrivateIP }}:4648"
}

server {
  enabled          = true,
  bootstrap_expect = 1
}
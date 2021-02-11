log_level = "DEBUG"

name       = "client1"
region     = "EU"
datacenter = "1"

data_dir   = "/nomad/data/"

bind_addr = "0.0.0.0"

client {
  enabled = true
  servers = ["192.168.0.2:4647"]
}

ports {
  http = 5656
}

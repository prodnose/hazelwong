data digitalocean_ssh_key sshkey {
  name = "fred"
}

data "digitalocean_image" "codeserver" {
  name = "codeserver"
}

resource "digitalocean_droplet" "codeserver" {
  name     = var.codeserver_domain
  image    = data.digitalocean_image.codeserver.id
  size     = var.DO_size
  region   = var.DO_region
  ssh_keys = [data.digitalocean_ssh_key.abc.id]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key)
    host        = self.ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      "sed -e 's/__CHANGE_THIS__/${var.codeserver_password}/' -i /lib/systemd/system/code-server.service",
      "sed -e 's/__CHANGE_THIS__/${var.codeserver_fqdn}/' -i /etc/nginx/sites-available/code-server.conf",
      "systemctl daemon-reload",
      "systemctl restart code-server",
      "systemctl restart nginx"
    ]
  }
}

resource "local_file" "root_at_codeserver" {
  content         = "The IP address is ${digitalocean_droplet.codeserver.ipv4_address}"
  filename        = "root@${digitalocean_droplet.codeserver.ipv4_address}"
  file_permission = 644
}

resource "cloudflare_record" "codeserver" {
  zone_id = data.cloudflare_zone.chuklee_zone.id
  name    = var.codeserver_domain
  type    = "A"
  value   = digitalocean_droplet.codeserver.ipv4_address
  proxied = true
}

output "codeserver_ipv4_address" {
  value = digitalocean_droplet.codeserver.ipv4_address
}

data digitalocean_ssh_key mykey {
    name = "fred"
}

data docker_image dovbear_image {
  name  = "chukmunnlee/dov-bear:v2"
}

resource digitalocean_ssh_key hazel {
    name = "hazel"
    public_key = file("/opt/tmp/hazel.pub")
}

resource digitalocean_droplet nginx {
    name = "nginx"
    image = var.DO_image
    size = var.DO_size
    region = var.DO_region
    ssh_keys = [ digitalocean_ssh_key.hazel.id ]

    connection {
        type = "ssh"
        user = "root"
        host = self.ipv4_address
        private_key = file("~/.ssh/id_rsa")
    }
    provisioner remote_exec {
        inline = [
            "apt update",
            "apt install -y nginx",
            "systemctl enable nginx",
            "systemctl start nginx",
        ]
    }
    provisioner_file {
        source = "./${local_file.nginx_conf.filename}"
        destination = "/etc/nginx/nginx.conf"
    }
    provisioner remote_exec {
        inline = [
            "systemctl restart nginx"
        ]
    }
}

resource local_file nginx_conf {
    filename = "nginx.conf"
    content = templatefile("nginx.conf.tftpl", {
        docker_host = "128.199.182.80"
        container_ports = local.ports
    })
}

output nginx_ip {
    description = "Nginx IP"
    value = digitalocean_droplet.nginx.ipv4_address
}

output container_ports {
    description = "container_ports"
    value = local.ports
}
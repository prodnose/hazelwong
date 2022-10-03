data digitalocean_ssh_key mykey {
    name = "fred"
}

resource digitalocean_droplet codeserver {
    name = "codeserver"
    image = var.DO_image
    size = var.DO_size
    region = var.DO_region
    ssh_keys = [ data.digitalocean_ssh_key.mykey.id ]
}

resource local_file root_at_codeserver {
    content = "The IP address is ${digitalocean_droplet.codeserver.ipv4_address}"
    filename = "root@${digitalocean_droplet.codeserver.ipv4_address}"
    file_permission = 644
}

resource local_file inventory {
    filename = "inventory.yaml"
    content = templatefile("inventory.yaml.tftpl", {
        private_key = var.private_key
        droplet_ip = digitalocean_droplet.codeserver.ipv4_address
        codeserver_domain: "codeserver-${digitalocean_droplet.codeserver.ipv4_address}.nip.io"
        codeserver_password: var.codeserver_password
    })
    file_permission = 644
}

output codeserver_ip {
    value = digitalocean_droplet.codeserver.ipv4_address
}
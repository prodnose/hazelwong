variable DO_token {
    type = string
    sensitive = true
}

variable DO_image {
    type = string
    default = "ubuntu-20-04-x64"
}

variable DO_size {
    type = string
    default = "s-1vcpu-1gb"
}

variable DO_region {
    type = string
    default = "sgp1"
}

source digitalocean codeserver {
    api_token = var.DO_token
    region = var.DO_region
    image = var.DO_image
    size = var.DO_size
    snapshot_name = "codeserver"
    ssh_username = "root"
}

build {
    sources = [
        "source.digitalocean.codeserver"
    ]
    provisioner ansible {
        playbook_file = "playbook.yaml"
        extra_args = [
            "-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa"
        ]
    }
}
terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.16.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "linode" {
  token = var.token
}

provider "cloudflare" {
  email   = var.email
  api_key = var.api_key
}

resource "linode_instance" "cluster-manager" {
  image           = "linode/debian10"
  label           = "cluster-manager"
  region          = "us-east"
  type            = "g6-standard-1"
  authorized_keys = [ var.public_key ]
  root_pass       = random_string.password.result

  provisioner "remote-exec" {
    inline = [
      "hostnamectl set-hostname cluster-manager",
      "apt -y update",
      "apt -y install curl wget htop",
      "export K3S_TOKEN=${var.token}",
      "curl -sfL https://get.k3s.io | sh -",
      "kubectl apply -n portainer -f https://raw.githubusercontent.com/portainer/k8s/master/deploy/manifests/portainer/portainer-lb.yaml"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      agent       = false
      private_key = var.private_key
      host        = self.ip_address
    }
  }
}

resource "cloudflare_record" "cluster-manager" {
  zone_id = var.zone_id
  name = "cluster-manager"
  value = linode_instance.cluster-manager.ip_address
  type = "A"
  depends_on = [ linode_instance.cluster-manager ]
}

resource "linode_instance" "cluster-worker" {
  image           = "linode/debian10"
  label           = "cluster-worker"
  region          = "us-east"
  type            = "g6-standard-1"
  authorized_keys = [ var.public_key ]
  root_pass       = random_string.password.result
  depends_on = [ cloudflare_record.cluster-manager ]

  provisioner "remote-exec" {
    inline = [
      "hostnamectl set-hostname cluster-worker",
      "apt -y update",
      "apt -y install curl wget htop",
      "export K3S_TOKEN=${var.token}",
      "export K3S_URL=https://cluster-manager.${var.zone_name}:6443",
      "curl -sfL https://get.k3s.io | sh -"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      agent       = false
      private_key = var.private_key
      host        = self.ip_address
    }
  }
}

resource "cloudflare_record" "cluster-worker" {
  zone_id = var.zone_id
  name = "cluster-worker"
  value = linode_instance.cluster-worker.ip_address
  type = "A"
  depends_on = [ linode_instance.cluster-worker ]
}

resource "local_file" "cluster-manager-ip" {
  content  = linode_instance.cluster-manager.ip_address
  filename = "cluster-manager-ip"
}


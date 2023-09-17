resource "null_resource" "execute_script" {
  provisioner "local-exec" {
    command = "./prerequisite.sh"
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version = " 0.25.0"
  set {
    name  = "server.ha.enabled"
    value = "true"
  }
  set{
    name="server.ha.raft.enabled"
    value = "true"
  }
  depends_on = [null_resource.execute_script]
}

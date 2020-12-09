resource "kubernetes_service_account" "jenkins-service-account" {
  metadata {
    name      = "jenkins"
    namespace = "jenkins"
  }
}


resource "kubernetes_role_binding" "jenkens-service-account-binding" {
  metadata {
    name      = "jenkins-service-account-rolebinding"
    namespace = "jenkins"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "jenkins"
    namespace = "jenkins"
  }
}

resource "kubernetes_secret" "jenkins-service-account-token" {
  metadata {
    name      = "jenkins-service-account-token"
    namespace = "jenkins"
    annotations = {
      "kubernetes.io/service-account.name" : "jenkins"
    }
  }
  type = "kubernetes.io/service-account-token"
  depends_on = [
    kubernetes_service_account.jenkins-service-account
  ]
}

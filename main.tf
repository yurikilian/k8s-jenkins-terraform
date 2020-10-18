resource "kubernetes_namespace" "jenkins-namespace" {
  metadata {
    name = "jenkins"
  }
}

resource "kubernetes_persistent_volume" "jenkins-volume" {
  metadata {
    name = "jenkins-volume"
  }
  spec {
    access_modes = [
      "ReadWriteMany"
    ]
    capacity = {
      storage = "20Gi"
    }

    persistent_volume_source {
      host_path {
        path = "/data/jenkins-volume"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jenkins-pvc" {
  metadata {
    name = "jenkins-pvc"
    namespace = "jenkins"
  }
  spec {
    access_modes = [
      "ReadWriteMany"
    ]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
  depends_on = [
    kubernetes_persistent_volume.jenkins-volume
  ]
}

resource "kubernetes_service_account" "jenkins-service-account" {
  metadata {
    name = "jenkins"
    namespace = "jenkins"
  }
}


resource "kubernetes_role_binding" "jenkens-service-account-binding" {
  metadata {
    name = "jenkins-service-account-rolebinding"
    namespace = "jenkins"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "admin"
  }
  subject {
    kind = "ServiceAccount"
    name = "jenkins"
    namespace = "jenkins"
  }
}

resource "kubernetes_secret" "jenkins-service-account-token" {
  metadata {
    name = "jenkins-service-account-token"
    namespace = "jenkins"
    annotations = {
      "kubernetes.io/service-account.name": "jenkins"
    }
  }
  type = "kubernetes.io/service-account-token"
  depends_on = [
    kubernetes_service_account.jenkins-service-account
  ]
}

resource "kubernetes_deployment" "jenkins-deployment" {
  metadata {
    name = "jenkins"
    namespace = "jenkins"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app:"jenkins"
      }
    }
    template {
      metadata {
        labels = {
          app: "jenkins"
        }
      }

      spec {
        service_account_name = "jenkins"
        container {
          name = "jenkins"
          image = "jenkins/jenkins:lts"

          port {
            name = "http-port"
            container_port = 8080
          }
          port {
            name = "jnlp-port"
            container_port = 50000
          }

          env {
            name = "JAVA_OPTS"
            value = "-Djenkins.install.runSetupWizard=false"
          }

          volume_mount {
            mount_path = "/var/jenkins_home"
            name = "jenkins-home-volume"
          }

          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name = "jenkins-service-account-secret"
          }
        }
        volume {
          name = "jenkins-home-volume"
          persistent_volume_claim {
            claim_name = "jenkins-pvc"
          }
        }

        volume {
          name = "jenkins-service-account-secret"
          secret {
            secret_name = "jenkins-service-account-token"
          }
        }

      }
    }
  }
  depends_on = [
    kubernetes_persistent_volume_claim.jenkins-pvc,
    kubernetes_secret.jenkins-service-account-token
  ]
}

resource "kubernetes_service" "jenkins-service" {
  metadata {
    namespace = "jenkins"
    name = "jenkins"
  }
  spec {
    type = "NodePort"
    port {
      port = 8080
      target_port = "8080"
    }

    selector = {
      app: "jenkins"
    }
  }
}
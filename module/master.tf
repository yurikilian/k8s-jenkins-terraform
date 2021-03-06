resource "kubernetes_config_map" "jenkins-pre-install-script" {
  metadata {
    name      = "jenkins-pre-install-configmap"
    namespace = "jenkins"
  }
  data = {
    "jenkins-pre-install.sh" = file("jenkins-pre-install.sh")
  }
}
resource "kubernetes_deployment" "jenkins-deployment" {
  metadata {
    name      = "jenkins"
    namespace = "jenkins"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app : "jenkins"
      }
    }

    template {
      metadata {
        labels = {
          app : "jenkins"
        }
      }

      spec {
        service_account_name = "jenkins"

        init_container {
          name  = "jenkins-pre-install"
          image = "jenkins/jenkins:lts"

          command = ["./var/init-scripts/jenkins-pre-install.sh"]
          args    = var.jenkins.plugins


          volume_mount {
            name       = "jenkins-pre-install"
            mount_path = "/var/init-scripts"
          }

          volume_mount {
            name       = "jenkins-home-volume"
            mount_path = "/var/jenkins_home"
          }
        }

        container {
          name  = "jenkins"
          image = "jenkins/jenkins:lts"

          port {
            name           = "http-port"
            container_port = 8080
          }
          port {
            name           = "jnlp-port"
            container_port = 50000
          }

          env {
            name  = "JAVA_OPTS"
            value = "-Djenkins.install.runSetupWizard=false"
          }

          volume_mount {
            mount_path = "/var/jenkins_home"
            name       = "jenkins-home-volume"
          }

          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name       = "jenkins-service-account-secret"
          }
        }

        volume {
          name = "jenkins-pre-install"
          config_map {
            name         = "jenkins-pre-install-configmap"
            default_mode = "0755"
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
    kubernetes_config_map.jenkins-pre-install-script,
    kubernetes_persistent_volume_claim.jenkins-pvc,
    kubernetes_secret.jenkins-service-account-token
  ]
}


resource "kubernetes_service" "jenkins-service" {
  metadata {
    namespace = "jenkins"
    name      = "jenkins"
  }
  spec {
    type = "NodePort"
    port {
      port        = 8080
      target_port = "8080"
    }

    selector = {
      app : "jenkins"
    }
  }
}

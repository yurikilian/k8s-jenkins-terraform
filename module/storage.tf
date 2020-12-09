resource "kubernetes_persistent_volume" "jenkins-volume" {
  metadata {
    name = "jenkins-volume"
  }
  spec {
    storage_class_name = "jenkins-storage"
    access_modes = [
      "ReadWriteMany"
    ]
    capacity = {
      storage = "10Gi"
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
    name      = "jenkins-pvc"
    namespace = "jenkins"
  }
  spec {
    storage_class_name = "jenkins-storage"
    access_modes = [
      "ReadWriteMany"
    ]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = "jenkins-volume"
  }
  depends_on = [
    kubernetes_persistent_volume.jenkins-volume
  ]
}

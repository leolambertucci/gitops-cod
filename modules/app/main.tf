locals {
  helm_values = yamlencode({
    nameOverride = var.name
    replicaCount = var.replicas

    image = {
      repository = split(":", var.image)[0]
      tag        = length(split(":", var.image)) > 1 ? split(":", var.image)[1] : "latest"
      pullPolicy = "IfNotPresent"
    }

    service = {
      type       = "ClusterIP"
      port       = 80
      targetPort = var.port
    }

    containerPort = var.port

    readinessProbe = {
      path = "/"
      initialDelaySeconds = 5
      periodSeconds       = 10
    }

    resources = {
      requests = {
        cpu    = "50m"
        memory = "64Mi"
      }
      limits = {
        cpu    = "100m"
        memory = "128Mi"
      }
    }

    networkPolicy = {
      enabled = true
    }
  })
}
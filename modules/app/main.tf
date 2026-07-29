
locals {
  image_parts = split(":", var.image)
  image_name  = local.image_parts[0]
  image_tag   = length(local.image_parts) > 1 ? local.image_parts[1] : "latest"

  helm_values = yamlencode({
    nameOverride = var.name
    replicaCount = var.replicas

    image = {
      repository = local.image_name
      tag        = local.image_tag
      pullPolicy = "IfNotPresent"
    }

    service = {
      type       = "ClusterIP"
      port       = 80
      targetPort = var.port
    }

    containerPort = var.port

    readinessProbe = {
      path                = "/"
      initialDelaySeconds = 5
      periodSeconds       = 10
    }

    livenessProbe = {
      path                = "/"
      initialDelaySeconds = 15
      periodSeconds       = 20
      failureThreshold    = 3
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
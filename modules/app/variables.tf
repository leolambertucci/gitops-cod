variable "name" {
  description = "Application name used by the Helm chart"
  type        = string
}

variable "image" {
  description = "Container image "
  type        = string

  validation {
    condition     = length(var.image) > 0
    error_message = "Image cannot be empty."
  }
}

variable "replicas" {
  description = "Number of pod replicas to deploy. Minimum 1 for availability."
  type        = number

  validation {
    condition     = var.replicas > 0
    error_message = "Replicas must be at least 1"
  }
}

variable "port" {
  description = "Container port exposed"
  type        = number

  validation {
    condition     = var.port >= 1 && var.port <= 65535
    error_message = "Port must be between 1 and 65535"
  }
}
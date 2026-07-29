variable "name" {
  description = "Application name used by the Helm chart"
  type        = string
}

variable "image" {
  description = "Container image "
  type        = string
}

variable "replicas" {
  description = "Replica count"
  type        = number
}

variable "port" {
  description = "Container port exposed by the app."
  type        = number
}
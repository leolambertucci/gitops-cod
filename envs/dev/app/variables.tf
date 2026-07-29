variable "name" {
  description = "Application name used by the Helm chart."
  type        = string
}

variable "image" {
  description = "Container image in repository:tag format."
  type        = string
}

variable "replicas" {
  description = "Desired replica count."
  type        = number
}

variable "port" {
  description = "Container port exposed by the application."
  type        = number
}
terraform {
  source = "../../../modules/app"
}

inputs = {
  name     = "hello-world-app"
  image    = "nginxdemos/hello:plain-text"
  replicas = 2
  port     = 80
}
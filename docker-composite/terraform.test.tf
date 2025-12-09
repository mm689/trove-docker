
terraform {
  required_version = "= 1.14.1"

  required_providers {
    aws = {
      version = "= 6.25.0"
    }
    external = {
      version = "= 2.3.5"
    }
    local = {
      version = "= 2.6.1"
    }
    null = {
      # Not pre-installed: this alone should cause an install
      version = "~> 3.2.4"
    }
    time = {
      version = "= 0.13.1"
    }
  }
}

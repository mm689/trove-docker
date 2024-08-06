
terraform {
  required_version = "1.9.1"

  required_providers {
    aws = {
      version = "5.62.0"
    }
    external = {
      version = "2.3.3"
    }
    local = {
      version = "2.5.1"
    }
    null = {
      # Not pre-installed: this alone should cause an install
      version = "~> 3.2.0"
    }
    time = {
      version = "0.12.0"
    }
  }
}

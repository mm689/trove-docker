
terraform {
  required_version = "1.5.6"

  required_providers {
    aws = {
      version = "5.14.0"
    }
    local = {
      version = "2.4.0"
    }
    null = {
      # Not pre-installed: this alone should cause an install
      version = "~> 3.1.0"
    }
    template = {
      version = "2.2.0"
    }
    time = {
      version = "0.9.1"
    }
  }
}

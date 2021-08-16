
terraform {
  required_version = "1.0.4"

  required_providers {
    aws = {
      version = "3.42.0"
    }
    local = {
      version = "2.1.0"
    }
    null = {
      # Not pre-installed: this alone should cause an install
      version = "~> 3.1.0"
    }
    template = {
      version = "2.2.0"
    }
    time = {
      version = "0.7.1"
    }
  }
}

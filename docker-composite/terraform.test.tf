
terraform {
  required_version = "1.2.3"

  required_providers {
    aws = {
      version = "4.24.0"
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

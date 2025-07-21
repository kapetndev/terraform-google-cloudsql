terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.71.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
  required_version = ">= 1.0"
}

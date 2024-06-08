variable "namespace" {
  type    = string
  default = "qhcv"
}

variable "vaulturl" {
  type    = string
  default = "http://vault.qhcv.localdev:8200"
}

variable "allowed_domains" {
  type    = list(string)
  default = ["qhcv"]
}

variable "organisation" {
  type    = string
  default = "qhcv"
}

variable "country" {
  type    = string
  default = "AU"
}

variable "locality" {
  type    = string
  default = "Melbourne"
}

variable "ou" {
  type    = string
  default = "IDAM"
}

variable "hostnames" {
  default = {
    "fram" = {
      "tls" : { "namespace" : "qhcv", "common_name" : "localhost", "alt_names" : ["localhost", "fram", "*.qhcv.localhost", "*.qhcv.localdev"] }
    },
    "frim" = {
      "tls" : { "namespace" : "qhcv", "common_name" : "localhost", "alt_names" : ["localhost", "frim", "*.qhcv.localhost", "*.qhcv.localdev"] }
      "selfservice" : { "common_name" : "selfservice" }
    },
    "frig" = {
      "tls" : { "namespace" : "qhcv", "common_name" : "localhost", "alt_names" : ["localhost", "frig", "*.qhcv.localhost", "*.qhcv.localdev"] }
    },
    "frds" = {
      "tls" : { "namespace" : "qhcv", "common_name" : "localhost", "alt_names" : ["localhost", "frdsamconfig", "frdsuser", "frdsamcts", "frdsidm", "*.qhcv.localhost", "*.qhcv.localdev"] }
    }
  }
}

locals {
  helper_list = flatten([for service, value in var.hostnames :
    flatten([for certificate, config in value :
      {
        "service"     = service,
        "certificate" = certificate,
        "config"      = config
      }
    ])
  ])
}

locals {
  clients = {
    "openidm-admin" = { "provider" : "frim", "password" : "" }
    "frig"          = { "provider" : "frig", password : "changeit" }
    "cticookie"     = { "provider" : "frig", password : "changeit" }
  }
}

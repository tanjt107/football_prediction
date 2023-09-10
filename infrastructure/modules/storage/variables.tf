variable "names" {
  description = "Bucket name."
  type        = list(string)
}

variable "suffix" {
  description = "Suffixes used to generate the bucket name."
  type        = string
  default     = ""
}

variable "location" {
  description = "Bucket location."
  type        = string
}

variable "project_id" {
  description = "Bucket project id."
  type        = string
}

variable "force_destroy" {
  description = "Defaults to false."
  type        = bool
  default     = false
}

variable "files" {
  description = "Map of lowercase unprefixed name => list of file objects."
  type        = map(list(string))
  default     = {}
}

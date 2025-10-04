variable "nodes" {
  description = "Кількість нод"
  default     = 1
}

variable "cpus" {
  description = "CPU на ноду"
  default     = 3
}

variable "memory" {
  description = "RAM на ноду (MB)"
  default     = 8192
}

variable "disk_size" {
  description = "Disk size на ноду (GB)"
  default     = 20
}

variable "driver" {
  description = "Драйвер Minikube"
  default     = "virtualbox"
}

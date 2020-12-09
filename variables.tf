variable "jenkins" {
  type = object({
    plugins = list(string)
  })
}

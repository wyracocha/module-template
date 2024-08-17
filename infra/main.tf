resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo This command will execute whenever the configuration changes"
  }
}
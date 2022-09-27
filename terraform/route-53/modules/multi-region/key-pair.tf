# Create key-pair for logging into EC2
resource "tls_private_key" "private-key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "key-pair" {
  key_name = "key-pair"
  public_key = tls_private_key.private-key.public_key_openssh
}

resource "local_sensitive_file" "pem-file" {
  filename = "${path.root}/${aws_key_pair.key-pair.key_name}.pem"
  file_permission = "600"
  content = tls_private_key.private-key.private_key_pem
}
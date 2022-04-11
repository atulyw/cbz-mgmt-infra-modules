locals {
  user_data = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install default-jre -y
EOF
}
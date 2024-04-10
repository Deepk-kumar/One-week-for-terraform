#!/bin/bash

# Check if Terraform is already installed
if command -v terraform &> /dev/null; then
    echo "Terraform is already installed."
    exit 0
fi

# Add HashiCorp GPG key to apt
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository to apt sources
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update package index and install Terraform
sudo apt update && sudo apt install terraform

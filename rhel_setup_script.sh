#!/bin/bash

# RHEL Development Environment Setup Script
# Usage: ./setup-dev-env.sh

set -e  # Exit on any error

echo "=== Starting RHEL Development Environment Setup ==="

# Update system
echo "Updating system packages..."
sudo dnf update -y

# Install Git
echo "Installing Git..."
sudo dnf install -y git

# Install JDK (OpenJDK 17 - adjust version as needed)
echo "Installing OpenJDK 17..."
sudo dnf install -y java-17-openjdk java-17-openjdk-devel

# Set JAVA_HOME
echo "Setting JAVA_HOME..."
JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which java))))
echo "export JAVA_HOME=$JAVA_HOME_PATH" >> ~/.bashrc
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc

# Install Maven
echo "Installing Maven..."
sudo dnf install -y maven

# Install wget and curl (useful utilities)
echo "Installing additional utilities..."
sudo dnf install -y wget curl unzip

# Verify installations
echo "=== Verifying installations ==="
java -version
mvn -version
git --version

echo "=== Setup completed successfully! ==="
echo "Please run 'source ~/.bashrc' or restart your terminal to apply environment variables."
echo ""
echo "Installed versions:"
echo "- Java: $(java -version 2>&1 | head -1)"
echo "- Maven: $(mvn -version 2>&1 | head -1)"
echo "- Git: $(git --version)"
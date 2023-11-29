#!/bin/bash

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

# Set noninteractive mode to avoid prompts during package installation
export DEBIAN_FRONTEND=noninteractive

# Use apt if available, otherwise use apt-get
APT_COMMAND="apt"
if ! command -v $APT_COMMAND &> /dev/null; then
  APT_COMMAND="apt-get"
fi

echo "Updating package list..."
$APT_COMMAND update

# Check if update was successful
if [ $? -eq 0 ]; then
  echo "Package list update successful."
else
  echo "Package list update failed. Please check for errors."
  exit 1
fi

echo "Checking if software-properties-common is installed..."
if ! dpkg -l | grep -q software-properties-common; then
  echo "software-properties-common is not installed. Installing..."
  $APT_COMMAND install -y software-properties-common

  # Check if installation was successful
  if [ $? -eq 0 ]; then
    echo "software-properties-common installation successful."
  else
    echo "software-properties-common installation failed. Please check for errors."
    exit 1
  fi
else
  echo "software-properties-common is already installed."
fi

echo "Installing Ansible..."

# Add Ansible repository and update package list
apt-add-repository -y --update ppa:ansible/ansible

# Install Ansible
$APT_COMMAND install -y ansible

# Check if Ansible installation was successful
if [ $? -eq 0 ]; then
  echo "Ansible installation successful."
else
  echo "Ansible installation failed. Please check for errors."
  exit 1
fi

# Check if Ansible is in the system's PATH
if ! command -v ansible &> /dev/null; then
  echo "Ansible not found in PATH. Installing python-software-properties..."
  $APT_COMMAND install -y python-software-properties

  # Check if python-software-properties installation was successful
  if [ $? -eq 0 ]; then
    echo "python-software-properties installation successful."
  else
    echo "python-software-properties installation failed. Please check for errors."
    exit 1
  fi
fi

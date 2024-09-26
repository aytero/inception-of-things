#!/bin/bash

# Ensure .ssh directory exists
mkdir -p /home/vagrant/.ssh

# Append the public key to authorized_keys
cat /tmp/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys

# Set the appropriate permissions
chmod 600 /home/vagrant/.ssh/authorized_keys
chmod 700 /home/vagrant/.ssh

# Set ownership to vagrant user
chown -R vagrant:vagrant /home/vagrant/.ssh

# Clean up temporary key files
rm /tmp/id_rsa.pub /tmp/id_rsa
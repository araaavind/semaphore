#!/bin/bash
set -eu

# ==================================================================================== #
# VARIABLES
# ==================================================================================== #

# Force all output to be presented in en_US for the duration of this script
export LC_ALL=en_US.UTF-8

# ==================================================================================== #
# SCRIPT LOGIC
# ==================================================================================== #

# Update package lists
apt update

# Install Redis server
apt --yes install redis-server

# Backup the original Redis configuration
cp /etc/redis/redis.conf /etc/redis/redis.conf.bak

# Configurations for Redis are directly done in the server without using this script

# Set up memory overcommit to ensure Redis can save its data properly
echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
sysctl vm.overcommit_memory=1

# Restart Redis to apply changes
systemctl restart redis-server

# Enable Redis to start at boot
systemctl enable redis-server

# Check Redis status
systemctl status redis-server

echo "Redis installation completed!"

echo "Script complete!"

#!/bin/bash

# Linux Cache Cleanup and Optimization Script
# Description: This script cleans up cache and optimizes memory usage on Linux systems.
# Use with caution and make sure you understand each step before running.

# Function to check if the script is run as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "This script must be run as root. Please use sudo."
        exit 1
    fi
}

# Function to prompt for confirmation
confirm() {
    read -p "Are you sure you want to proceed? This may affect system performance. (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            echo "Proceeding..."
        ;;
        * )
            echo "Operation cancelled."
            exit 0
        ;;
    esac
}

# Main cleanup function
cleanup() {
    echo "Starting cleanup process..."

    # Flush file system buffers
    sync
    echo "File system buffers flushed."

    # Clear pagecache, dentries, and inodes
    echo 3 > /proc/sys/vm/drop_caches
    echo "Page cache, dentries, and inodes cleared."

    # Clear apt-get cache if apt-get is available
    if command -v apt-get &> /dev/null; then
        apt-get clean
        echo "apt-get cache cleared."
    else
        echo "apt-get not found. Skipping apt cache cleanup."
    fi

    # Clear and re-enable swap
    swapoff -a && swapon -a
    echo "Swap cleared and re-enabled."

    # Clear systemd journal logs older than 1 day
    if command -v journalctl &> /dev/null; then
        journalctl --vacuum-time=1d
        echo "Systemd journal logs older than 1 day cleared."
    else
        echo "journalctl not found. Skipping journal log cleanup."
    fi

    echo "Cleanup process completed."
}

# Function to optimize system settings
optimize() {
    echo "Optimizing system settings..."

    # Set swappiness value to optimize memory usage
    sysctl vm.swappiness=10
    echo "Swappiness set to 10."

    # Set vfs_cache_pressure value to optimize cache memory usage
    sysctl vm.vfs_cache_pressure=50
    echo "VFS cache pressure set to 50."

    # Apply the changes immediately
    sysctl -p
    echo "System settings optimized and applied."
}

# Main execution
check_root
echo "This script will clean up cache and optimize memory usage on your Linux system."
confirm
cleanup
optimize
echo "Cache cleared and system optimized. It's recommended to monitor your system's performance after these changes."
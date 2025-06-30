#!/bin/bash

# Color functions
log() {
    echo -e "\033[1;34m[*] $1\033[0m"       # blue
}
success() {
    echo -e "\033[1;32m[+] $1\033[0m"       # green
}
warning() {
    echo -e "\033[1;33m[!] $1\033[0m"       # yellow / orange
}
error() {
    echo -e "\033[1;31m[-] $1\033[0m"       # red
}

# Lists of packages by installer
APT_PACKAGES=(ffuf sqlmap gobuster python3-bs4 python3-requests)
SNAP_PACKAGES=(seclists)

# Install via apt-get
install_apt() {
    log "Updating package list..."
    sudo apt-get update -y

    for pkg in "${APT_PACKAGES[@]}"; do
        log "Installing $pkg via apt-get..."
        if sudo apt-get install -y "$pkg"; then
            success "$pkg installed"
        else
            error "Failed to install $pkg"
        fi
    done
}

# Install via snap
install_snap() {
    for pkg in "${SNAP_PACKAGES[@]}"; do
        log "Installing $pkg via snap..."
        if sudo snap install "$pkg" --classic; then
            success "$pkg installed"
        else
            error "Failed to install $pkg"
        fi
    done
}

# Run all installs
install_apt
install_snap

success "Web module installed successfully."


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

# Uninstall via apt-get
uninstall_apt() {
    for pkg in "${APT_PACKAGES[@]}"; do
        log "Removing $pkg via apt-get..."
        if sudo apt-get remove -y "$pkg"; then
            success "$pkg removed"
        else
            warning "Failed to remove $pkg or package not installed"
        fi
    done
    # Optionally autoremove unused dependencies
    log "Cleaning up unused packages..."
    sudo apt-get autoremove -y
}

# Uninstall via snap
uninstall_snap() {
    for pkg in "${SNAP_PACKAGES[@]}"; do
        log "Removing $pkg via snap..."
        if sudo snap remove "$pkg"; then
            success "$pkg removed"
        else
            warning "Failed to remove $pkg or package not installed"
        fi
    done
}

# Run all uninstallations
uninstall_apt
uninstall_snap

success "Web module uninstalled successfully."

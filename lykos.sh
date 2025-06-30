#!/bin/bash

MODULES_DIR="$(pwd)/modules"
UNINSTALL_DIR="$(pwd)/uninstall"
LOG_DIR="$(pwd)/logs"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
SESSION_LOG="$LOG_DIR/session-$TIMESTAMP.log"

function usage() {
    echo "Usage:"
    echo "  lykos -m <module>           Install module"
    echo "  lykos -u <module>           Uninstall module"
    echo "  lykos -l			List all modules"
    echo "  lykos -m all                Install all modules"
    echo "  lykos -u all                Uninstall all modules"
    exit 1
}

function list_modules() {
    echo "Installable modules:"
    for script in "$MODULES_DIR"/*.sh; do
        mod_name=$(basename "$script" .sh)
        echo "  - $mod_name"
    done
}


function install_module() {
    local module="$1"
    if [[ "$module" == "all" ]]; then
        for script in "$MODULES_DIR"/*.sh; do
            install_module "$(basename "$script" .sh)"
        done
    elif [[ -f "$MODULES_DIR/$module.sh" ]]; then
        echo "[+] Installing module: $module"
        bash "$MODULES_DIR/$module.sh" | tee -a "$SESSION_LOG"
    else
        echo "[-] Module '$module' not found."
    fi
}

function uninstall_module() {
    local module="$1"
    if [[ "$module" == "all" ]]; then
        for script in "$UNINSTALL_DIR"/*.sh; do
            uninstall_module "$(basename "$script" .sh)"
        done
    elif [[ -f "$UNINSTALL_DIR/$module.sh" ]]; then
        echo "[+] Uninstalling module: $module"
        bash "$UNINSTALL_DIR/$module.sh" | tee -a "$SESSION_LOG"
    else
        echo "[-] Uninstall script for module '$module' not found."
    fi
}

# Argument parsing
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -m) install_module "$2"; shift ;;
        -u) uninstall_module "$2"; shift ;;
        -l|--list) list_modules ;;
        *) usage ;;
    esac
    shift
done

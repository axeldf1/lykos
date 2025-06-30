#!/bin/bash

source data/packages.sh

MODULES_DIR="$(pwd)/modules"
UNINSTALL_DIR="$(pwd)/uninstall"
LOG_DIR="$(pwd)/logs"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
SESSION_LOG="$LOG_DIR/session-$TIMESTAMP.log"

log()     { echo -e "\033[1;34m[*] $1\033[0m"; }
success() { echo -e "\033[1;32m[+] $1\033[0m"; }
error()   { echo -e "\033[1;31m[-] $1\033[0m"; }

function usage() {
    echo "Usage:"
    echo "  lykos -m <module>           Install module"
    echo "  lykos -u <module>           Uninstall module"
    echo "  lykos -l			        List all modules"
    echo "  lykos -m all                Install all modules"
    echo "  lykos -u all                Uninstall all modules"
    exit 1
}

function list_modules() {
    echo "Installable modules:"

    source data/packages.sh

    declare -A categories=()
    declare -A seen_subcats=()

    # Collecte sous-catégories par catégorie
    for mod_name in "${!APT_PACKAGES[@]}"; do
        [[ "$mod_name" == "all" ]] && continue

        if [[ "$mod_name" == *"-"* ]]; then
            category="${mod_name%%-*}"
            subcat="${mod_name#*-}"
            # Initialise si besoin
            [[ -z "${categories[$category]}" ]] && categories[$category]=""
            # Ajoute sous-catégorie si pas déjà vue
            key="$category:$subcat"
            if [[ -z "${seen_subcats[$key]}" ]]; then
                categories[$category]+="$subcat "
                seen_subcats[$key]=1
            fi
        else
            # Module sans sous-catégorie (on l'ajoute avec un tiret vide)
            [[ -z "${categories[$mod_name]}" ]] && categories[$mod_name]=""
        fi
    done

    # Trie et affiche
    for cat in $(printf "%s\n" "${!categories[@]}" | sort); do
        echo "- $cat"
        # Trie sous-catégories
        read -ra subs <<< "${categories[$cat]}"
        IFS=$'\n' sorted_subs=($(sort <<<"${subs[*]}"))
        unset IFS
        for sub in "${sorted_subs[@]}"; do
            [[ -z "$sub" ]] && continue
            echo "    - $sub"
        done
    done
}

function install_module() {
    local mod="$1"
    declare -A apt_unique=()
    declare -A snap_unique=()

    if [[ "$mod" == *"-"* ]]; then
        # Sous-module unique, ex: web-discovery
        for pkg in ${APT_PACKAGES[$mod]}; do
            apt_unique["$pkg"]=1
        done
        for pkg in ${SNAP_PACKAGES[$mod]}; do
            snap_unique["$pkg"]=1
        done
    else
        # Module général : chercher tous les web-* dans APT_PACKAGES
        for key in "${!APT_PACKAGES[@]}"; do
            if [[ "$key" == "$mod"-* ]]; then
                for pkg in ${APT_PACKAGES[$key]}; do
                    apt_unique["$pkg"]=1
                done
                for pkg in ${SNAP_PACKAGES[$key]}; do
                    snap_unique["$pkg"]=1
                done
            fi
        done
    fi

    log "Installing APT packages for $mod..."
    for pkg in "${!apt_unique[@]}"; do
        log "Installing $pkg..."
        apt-get install -y "$pkg" && success "$pkg installed" || error "$pkg failed"
    done

    log "Installing SNAP packages for $mod..."
    for pkg in "${!snap_unique[@]}"; do
        [[ -n "$pkg" ]] && {
            log "Installing $pkg via snap..."
            snap install "$pkg" --classic && success "$pkg installed" || error "$pkg failed"
        }
    done
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

function run_module(){
    mod_name="$1"
    category="${mod_name%%-*}"
    subcat="${mod_name#*-}"
    path="modules/$category/$subcat.sh"
    echo $path
    [[ -f "$path" ]] && bash "$path" || echo "No run script for $runmod"
}

# Argument parsing
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -m) install_module "$2"; shift ;;
        -u) uninstall_module "$2"; shift ;;
        -l|--list) list_modules; shift ;;
        -r|--run) run_module "$2"; shift ;;
        *) usage ;;
    esac
    shift
done

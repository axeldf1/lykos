declare -A APT_PACKAGES
declare -A SNAP_PACKAGES

APT_PACKAGES["web-discovery"]="ffuf gobuster nmap python3-bs4 python3-requests curl"
APT_PACKAGES["web-lfi"]="ffuf curl"
APT_PACKAGES["web-sqli"]="sqlmap"

SNAP_PACKAGES["web-discovery"]="seclists"

# Tu peux faire un ALL si tu veux tout à terme
APT_PACKAGES["all"]="$(echo "${APT_PACKAGES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
SNAP_PACKAGES["all"]="$(echo "${SNAP_PACKAGES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"

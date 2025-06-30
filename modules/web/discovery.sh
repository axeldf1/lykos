#!/bin/bash

LOGFILE="logs/web-discovery-$(date +%Y%m%d_%H%M%S).log"

banner() {
    local text="$1"
    local line="##########################################################"
    local padding=$(( (54 - ${#text}) / 2 ))
    local pad_left=$(printf '%*s' "$padding")
    local pad_right=$pad_left
    # Ajuster si la longueur est impaire
    if (( (54 - ${#text}) % 2 != 0 )); then
        pad_right+=" "
    fi

    echo -e "\n$line"
    echo -e "#${pad_left}${text}${pad_right}#"
    echo -e "$line\n" | tee -a "$LOGFILE"
}

mkdir -p logs

banner "NMAP SCAN"
nmap -sC -sV "$TARGET_IP" | tee -a "$LOGFILE"

banner "FFUF"
ffuf -u "$TARGET_URL/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/common.txt -t 50 | tee -a "$LOGFILE"

banner "Gobuster"
gobuster dir -u "$TARGET_URL" -w /usr/share/wordlists/dirb/common.txt -t 50 | tee -a "$LOGFILE"

echo -e "\n✅ Discovery done. Full output saved in: $LOGFILE"

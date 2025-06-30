#!/bin/bash

chmod +x lykos.sh
ln -sf "$(pwd)/lykos.sh" /usr/local/bin/lykos
echo "[+] Lykos installed. Use “lykos -m web” for example."

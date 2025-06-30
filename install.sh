#!/bin/bash

chmod +x ccsht.sh
sudo ln -sf "$(pwd)/ccsht.sh" /usr/local/bin/lykos
echo "[+] Lykos installed. Use “lykos -m web” for example."

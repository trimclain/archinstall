#!/bin/bash

###############################################################################
# Edit logind.conf to suspend on power key press and when closing the lid
###############################################################################

CONF=/etc/systemd/logind.conf

check_and_update_line() {
    local pattern="$1"
    local line="$2"

    if grep -q "$pattern" "$CONF"; then
        sudo sed -i "/$pattern/s/.*/$line/" "$CONF"
    else
        echo "$line" | sudo tee -a "$CONF" > /dev/null
    fi
}

check_and_update_line '^#*HandlePowerKey=' "HandlePowerKey=suspend"
check_and_update_line '^#*HandleLidSwitch=' "HandleLidSwitch=suspend"

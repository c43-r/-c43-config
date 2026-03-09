#!/bin/bash

# Get memory info from /proc/meminfo (in KB)
MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_FREE=$(grep MemFree /proc/meminfo | awk '{print $2}')
BUFFERS=$(grep Buffers /proc/meminfo | awk '{print $2}')
CACHED=$(grep ^Cached /proc/meminfo | awk '{print $2}')
SRECLAIMABLE=$(grep SReclaimable /proc/meminfo | awk '{print $2}')

# htop calculation: Used = Total - Free - Buffers - Cached - SReclaimable
MEM_USED=$((MEM_TOTAL - MEM_FREE - BUFFERS - CACHED - SRECLAIMABLE))

# --- NEW LOGIC START ---
# Check if Used Memory is less than 1GB (1048576 KB)
if [ "$MEM_USED" -lt 1048576 ]; then
    # Convert KB to MB (divide by 1024)
    DISPLAY_USED=$(echo "$MEM_USED / 1024" | bc)
    UNIT_USED="MB"
else
    # Convert KB to GB (divide by 1024 twice)
    DISPLAY_USED=$(echo "scale=1; $MEM_USED / 1048576" | bc)
    UNIT_USED="GB"
fi

# Same logic for Total Memory (usually always GB)
TOTAL_GB=$(echo "scale=1; $MEM_TOTAL / 1048576" | bc)
TOTAL_FREE=$(echo "scale=1; $MEM_FREE / 1048576" | bc)   
# --- NEW LOGIC END ---

# Calculate percentage for the bar
PERCENT=$((MEM_USED * 100 / MEM_TOTAL))
FMT_USED=$(printf "%.1f" $DISPLAY_USED)
FMT_TOTAL_FREE=$(printf "%.1f" $(echo "$MEM_FREE / 1048576" | bc ))
BAR_SIZE=10
FILLED=$((PERCENT / BAR_SIZE))
EMPTY=$((BAR_SIZE - FILLED))
BAR="["
for i in $(seq 1 $FILLED); do BAR="$BAR|"; done
for i in $(seq 1 $EMPTY); do BAR="$BAR "; done
BAR="$BAR]"
# Output to i3blocks
echo "${FMT_USED} ${UNIT_USED} | ${TOTAL_FREE} GB"

# Optional: Color output (Green -> Yellow -> Red)
if [ $PERCENT -gt 85 ]; then
     echo "#FF0000" # Red
elif [ $PERCENT -gt 50 ]; then
     echo "#FFFF00" # Yellow
else
     echo "#00FF00" # Green
fi

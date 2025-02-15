#!/bin/sh

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

MOUNT_POINT="/mnt/mmcblk2p4"
TEST_FILE="${MOUNT_POINT}/fio_testfile"

MODEL=$(cat /tmp/sysinfo/model)
STORAGE_TYPE=$(lsblk -o NAME,TYPE,MOUNTPOINT | grep "$MOUNT_POINT" | awk '{print $2}')
FILESYSTEM=$(df -T $MOUNT_POINT | awk 'NR==2 {print $2}')
BLOCK_SIZE="4K"
TEST_SIZE="100M"

echo -e "${WHITE}Device Info:${RESET}"
echo -e "${CYAN}- Model: ${WHITE}$MODEL${RESET}"
echo -e "${CYAN}- Location Test: ${WHITE}${MOUNT_POINT}${RESET}"
echo -e "${CYAN}- Filesystem: ${WHITE}$FILESYSTEM${RESET}"
echo -e "${CYAN}- Block Size: ${WHITE}$BLOCK_SIZE${RESET}"
echo -e "${CYAN}- Test Size: ${WHITE}$TEST_SIZE${RESET}"
echo ""
echo -e "${YELLOW}📌 Running Storage Performance Test...${RESET}"
echo ""

# Function to extract bandwidth from fio output
extract_bw() {
    grep -E 'WRITE: bw=|READ: bw=' | awk -F'[:,( ]+' '{print $3, $4}'
}

# Test Write Throughput (Sequential)
SEQ_WRITE=$(fio --name=seq_write --rw=write --bs=1M --size=$TEST_SIZE --numjobs=1 --directory=$MOUNT_POINT --fsync=1 | extract_bw)
echo -e "${BLUE}📂 Test Write Throughput (Sequential Writes)${RESET}"
echo -e "${GREEN}WRITE: bw=${WHITE}${SEQ_WRITE}${RESET}"
echo ""

# Test Write IOPS (Random 4K)
RAND_WRITE=$(fio --name=rand_write --rw=randwrite --bs=4k --size=$TEST_SIZE --numjobs=1 --directory=$MOUNT_POINT --fsync=1 | extract_bw)
echo -e "${BLUE}🔄 Test Write IOPS (Random Writes 4K)${RESET}"
echo -e "${GREEN}WRITE: bw=${WHITE}${RAND_WRITE}${RESET}"
echo ""

# Test Read Throughput (Sequential)
SEQ_READ=$(fio --name=seq_read --rw=read --bs=1M --size=$TEST_SIZE --numjobs=1 --directory=$MOUNT_POINT | extract_bw)
echo -e "${BLUE}📂 Test Read Throughput (Sequential Reads)${RESET}"
echo -e "${GREEN}READ: bw=${WHITE}${SEQ_READ}${RESET}"
echo ""

# Test Read IOPS (Random 4K)
RAND_READ=$(fio --name=rand_read --rw=randread --bs=4k --size=$TEST_SIZE --numjobs=1 --directory=$MOUNT_POINT | extract_bw)
echo -e "${BLUE}🔄 Test Read IOPS (Random Reads 4K)${RESET}"
echo -e "${GREEN}READ: bw=${WHITE}${RAND_READ}${RESET}"
echo ""

# Remove Temp Files
rm -f $MOUNT_POINT/rand_read.0.0
rm -f $MOUNT_POINT/rand_write.0.0
rm -f $MOUNT_POINT/seq_read.0.0
rm -f $MOUNT_POINT/seq_write.0.0
echo -e "${YELLOW}✅ Test complete. Temporary files removed.${RESET}"

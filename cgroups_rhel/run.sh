#!/bin/bash
# This script works with RHEL6 and RHEL7
# Using cfs.quotas will limit the total CPU usage of your only process
# to a certain limit, and will not allow your application to go beyond
# that as with CPU.SHARES. 
#
# For more complex cgroup configurations, please check:
#
# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html-single/Resource_Management_Guide/

# Basic configuration, please change according to your needs:

# user or group to be caped. For group, use @ before the group name
CAP_USER=root
# percentage of memory to be caped 
CAP_MEM_PERC=65
# percentage of cfs quotas 
CAP_CPU_PERC=65
# number of read operations per second
DISK_RTPS=600
# number of write operations per second
DISK_WTPS=200

# Don't change the script from this point

# Variables
CFS_TOTAL=100000
TOTAL_CPU=${CAP_CPU_PERC}000
CPUS=$(grep -c proc /proc/cpuinfo)
CAPED_CPU=$(( $CPUS * $TOTAL_CPU ))
TOTAL_MEM=$(free -m | head -2 | tail -1 | awk '{print $2}')
CAPED_MEM=$(( ($TOTAL_MEM*$CAP_MEM_PERC) / 100 ))
CGROUP_PATH=/cgroup

# change defaults in cgrules.conf.orig and cgconfig.conf.orig
sed -e "s/CAPED_CPU/$CAPED_CPU/g" \
    -e "s/CAPED_MEM/$CAPED_MEM/g" \
    cgconfig.conf.orig > /etc/cgconfig.conf

sed -e "s/USER/$CAP_USER/g" \
    cgrules.conf.orig > /etc/cgrules.conf

# RHEL7 compatibility
if uname -a | grep el7
  then
   sed -i -e '1,6d' /etc/cgconfig.conf
   CGROUP_PATH=/sys/fs/cgroup
fi

# After writing the config files, restart the services
service cgconfig restart
service cgred restart

# Add blkio rules manually
while read -r line
do
echo "$line       $DISK_WTPS" >> $CGROUP_PATH/blkio/gss/blkio.throttle.write_iops_device
echo "$line       $DISK_RTPS" >> $CGROUP_PATH/blkio/gss/blkio.throttle.read_iops_device
done < <(dmsetup info -c | awk '{print $2":"$3}' | grep -v Maj)

# Print results
echo "######################"
echo "NUMER OF CPUS:" $CPUS, "CAPED_CPU:" $CAPED_CPU "out of" $CFS_TOTAL
echo "CAPED_MEM:" $CAPED_MEM

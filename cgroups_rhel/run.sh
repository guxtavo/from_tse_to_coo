# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html-single/Resource_Management_Guide/#Finding_a_Process
# https://www.digitalocean.com/community/tutorials/how-to-limit-resources-using-cgroups-on-centos-6

# Using cfs.quotas will limit the total CPU usage of your only process
# to a certain limit, and will not allow your application to go beyond
# that as with CPU.SHARES. 

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

# Don't change the script from here

CFS_TOTAL=100000
TOTAL_CPU=${CAP_CPU_PERC}000
CPUS=$(grep -c proc /proc/cpuinfo)
CAPED_CPU=$(( $CPUS * $TOTAL_CPU ))

DEVICE_LIST=$(dmsetup info -c | awk '{print $2":"$3}' | grep -v Maj)

TOTAL_MEM=$(free -m | head -2 | tail -1 | awk '{print $2}')
CAPED_MEM=$(( ($TOTAL_MEM*$CAP_MEM_PERC) / 100 ))


# change defaults in cgrules.conf.orig and cgconfig.conf.orig

sed -e "s/CAPED_CPU/$CAPED_CPU/g" \
    -e "s/CAPED_MEM/$CAPED_MEM/g" \
    cgconfig.conf.orig > /etc/cgconfig.conf

sed -e "s/USER/$CAP_USER/g" \
    cgrules.conf.orig > /etc/cgrules.conf

service cgconfig restart
service cgred restart

while read -r line
do
echo "$line       $DISK_WTPS" >> /cgroup/blkio/gss/blkio.throttle.write_iops_device
echo "$line       $DISK_RTPS" >> /cgroup/blkio/gss/blkio.throttle.read_iops_device
done < <(dmsetup info -c | awk '{print $2":"$3}' | grep -v Maj)

echo "######################"
echo "NUMER OF CPUS:" $CPUS, "CAPED_CPU:" $CAPED_CPU "out of" $CFS_TOTAL
echo "CAPED_MEM:" $CAPED_MEM

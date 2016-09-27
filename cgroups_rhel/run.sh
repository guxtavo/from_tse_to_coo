# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html-single/Resource_Management_Guide/#Finding_a_Process
# https://www.digitalocean.com/community/tutorials/how-to-limit-resources-using-cgroups-on-centos-6

CAP_USER=root
CPU_SHARES=50000   # total is 100000, so currently at half
CAP_MEM_PERC=80    # 80% of all memory
DISK_RTPS=500
DISK_WTPS=100

DEVICE_LIST=$(dmsetup info -c | awk '{print $2":"$3}' | grep -v Maj)
TOTAL_MEM=$(free -m | head -2 | tail -1 | awk '{print $2}')
CAPED_MEM=$(( ($TOTAL_MEM*$CAP_MEM_PERC) / 100 ))

# change defaults in cgrules.conf.orig and cgconfig.conf.orig

sed -e "s/CPU_SHARES/$CPU_SHARES/g" \
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

echo
cat /proc/self/cgroup

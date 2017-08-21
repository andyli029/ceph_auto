#!/bin/bash
#http://docs.ceph.com/docs/hammer/install/manual-deployment/#monitor-bootstrapping

#### var ####
prefix=192.168.124
array=( 174 175 )
#############

for i in ${array[@]}
do
	
	ip=$prefix.$i
	echo "$ip"

	scp /etc/ceph/* root@$ip:/etc/ceph/
	if [[ `echo $?` != 0 ]]
        then
                echo "cp ceph.conf error."
                break
        else
                echo "cp ceph.conf success."
        fi
	

	#ceph osd lspools && ceph -s && ps -ef |grep ceph-mon
#block

done

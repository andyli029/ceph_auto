#!/bin/bash
#http://docs.ceph.com/docs/hammer/install/manual-deployment/#monitor-bootstrapping
################ var ###### 
array=( 0 )
h=node176
###########################

for i in ${array[@]}
do
###### var ######
d=vdd1
uuid=a7f64266-0894-4f1e-a635-d0ffffb0e99$i
#################

:<<if_0
	ceph-disk prepare /dev/$d
	if [[ `echo $?` != 0 ]]
        then
                echo "1 error."
                break
        else
                echo "1 success."
        fi

	ceph-disk activate /dev/$d
        if [[ `echo $?` != 0 ]]
        then
                echo "2 error."
                break
        else
                echo "2 success."
        fi
if_0

#:<<BLOCK
	ceph osd create $uuid
	if [[ `echo $?` != 0 ]]
        then
                echo "3 error."
                break
        else
                echo "3 success."
        fi
	
	umount /var/lib/ceph/osd/ceph-$i
	rm -rf /var/lib/ceph/osd/ceph-$i
        mkdir /var/lib/ceph/osd/ceph-$i
	if [[ `echo $?` != 0 ]]
        then
                echo "4 error."
                break
        else
                echo "4 success."
        fi

        chown ceph:ceph -R /var/lib/ceph/osd/ceph-$i
        if [[ `echo $?` != 0 ]]
        then
                echo "4.1 error."
                break
        else
                echo "4.1 success."
        fi

	mkfs.xfs -f /dev/$d   
	if [[ `echo $?` != 0 ]]
        then
                echo "5 error."
                break
        else
                echo "5 success."
        fi

	mount -o noatime,nodiratime,inode64 /dev/$d /var/lib/ceph/osd/ceph-$i
	if [[ `echo $?` != 0 ]]
        then
                echo "5.1 error."
                break
        else
                echo "5.2 success."
        fi
        
	ceph-osd -i $i --mkfs --mkkey --osd-uuid $uuid
	if [[ `echo $?` != 0 ]]
	then
                echo "6 error."
                break
        else
                echo "6 success."
        fi

        chown ceph:ceph -R /var/lib/ceph/osd/ceph-$i
        if [[ `echo $?` != 0 ]]
        then
                echo "6.1 error."
                break
        else
                echo "6.1 success."
        fi

	ceph auth add osd.$i osd 'allow *' mon 'allow profile osd' -i /var/lib/ceph/osd/ceph-$i/keyring
        if [[ `echo $?` != 0 ]]
        then
                echo "7 error."
                break
        else
                echo "7 success."
        fi

        ceph osd crush add-bucket $h host
	if [[ `echo $?` != 0 ]]
        then
                echo "8 error."
                break
        else
                echo "8 success."
        fi

        ceph osd crush move $h root=default
	if [[ `echo $?` != 0 ]]
        then
                echo "9 error."
                break
        else
                echo "9 success."
        fi

        ceph osd crush add osd.$i 1.0 host=$h
	if [[ `echo $?` != 0 ]]
        then
                echo "10 error."
                break
        else
                echo "10 success."
        fi

	systemctl reset-failed ceph-osd@$i.service
        systemctl start ceph-osd@$i
	if [[ `echo $?` != 0 ]]
        then
                echo "11 error."
                break
        else
                echo "11 success."
        fi
#BLOCK

	ps -ef |grep ceph-osd && ceph osd tree
	#ceph osd lspools && ceph -s && ps -ef |grep ceph-mon
done

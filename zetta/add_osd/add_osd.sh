#!/bin/bash
#http://docs.ceph.com/docs/hammer/install/manual-deployment/#monitor-bootstrapping
array=( 4 )
d=vdd1
for i in ${array[@]}
do
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
:<<BLOCK
	ceph osd create a7f64266-0894-4f1e-a635-d0ffffb0e993
	if [[ `echo $?` != 0 ]]
        then
                echo "3 error."
                break
        else
                echo "3 success."
        fi

        mkdir /var/lib/ceph/osd/ceph-0
	if [[ `echo $?` != 0 ]]
        then
                echo "4 error."
                break
        else
                echo "4 success."
        fi

        chown ceph:ceph -R /var/lib/ceph/osd/ceph-0
        if [[ `echo $?` != 0 ]]
        then
                echo "4.1 error."
                break
        else
                echo "4.1 success."
        fi

	mkfs -t xfs /dev/sdb1   
	if [[ `echo $?` != 0 ]]
        then
                echo "5 error."
                break
        else
                echo "5 success."
        fi

        mount -o user_xattr /dev/sdb1 /var/lib/ceph/osd/ceph-0
	if [[ `echo $?` != 0 ]]
        then
                echo "5.1 error."
                break
        else
                echo "5.2 success."
        fi
        
	ceph-osd -i 0 --mkfs --mkkey --osd-uuid a7f64266-0894-4f1e-a635-d0ffffb0e993
	if [[ `echo $?` != 0 ]]
	then
                echo "6 error."
                break
        else
                echo "6 success."
        fi

	ceph auth add osd.0 osd 'allow *' mon 'allow profile osd' -i /var/lib/ceph/osd/ceph-0/keyring
        if [[ `echo $?` != 0 ]]
        then
                echo "7 error."
                break
        else
                echo "7 success."
        fi

        ceph osd crush add-bucket node03 host
	if [[ `echo $?` != 0 ]]
        then
                echo "8 error."
                break
        else
                echo "8 success."
        fi

        ceph osd crush move node03 root=default
	if [[ `echo $?` != 0 ]]
        then
                echo "9 error."
                break
        else
                echo "9 success."
        fi

        ceph osd crush add osd.0 1.0 host=node03
	if [[ `echo $?` != 0 ]]
        then
                echo "10 error."
                break
        else
                echo "10 success."
        fi

        systemctl start ceph-osd@0
	if [[ `echo $?` != 0 ]]
        then
                echo "11 error."
                break
        else
                echo "11 success."
        fi
BLOCK

	ps -ef |grep ceph-osd && ceph osd tree
	#ceph osd lspools && ceph -s && ps -ef |grep ceph-mon
done

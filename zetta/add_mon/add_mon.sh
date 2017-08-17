#!/bin/bash
#http://docs.ceph.com/docs/hammer/install/manual-deployment/#monitor-bootstrapping
prefix=192.168.124
array=( 176 )
for i in ${array[@]}
do
	
	ip=$prefix.$i
	echo "$ip"

	#rm -f /etc/ceph/ceph.conf
	if [[ `echo $?` != 0 ]]
        then
                echo "cp ceph.conf error."
                break
        else
                echo "cp ceph.conf success."
        fi
	
	rm -rf /var/lib/ceph/mon/ceph-node$i
	mkdir /var/lib/ceph/mon/ceph-node$i
        if [[ `echo $?` != 0 ]]
        then
                echo "12 error."
                break
        else
                echo "12 success."
        fi

	rm -rf /tmp/tmp_mon
	mkdir /tmp/tmp_mon
        if [[ `echo $?` != 0 ]]
        then
                echo "13 error."
                break
        else
                echo "13 success."
        fi

	ceph auth get mon. -o /tmp/tmp_mon/ceph.mon.keyring
        if [[ `echo $?` != 0 ]]
        then
                echo "13.1 error."
                break
        else
                echo "13.1 success."
        fi

        ceph mon getmap -o /tmp/tmp_mon/monmap
        if [[ `echo $?` != 0 ]]
        then
                echo "14 error."
                break
        else
                echo "14 success."
        fi

	ceph-mon --mkfs -i node$i --monmap /tmp/tmp_mon/monmap --keyring /tmp/tmp_mon/ceph.mon.keyring
        if [[ `echo $?` != 0 ]]
        then
                echo "15 error."
                break
        else
                echo "15 success."
        fi

        chown ceph:ceph -R /var/lib/ceph/mon/ceph-node$i
        if [[ `echo $?` != 0 ]]
        then
                echo "15.1error."
                break
        else
                echo "15.1 success."
        fi

	ceph mon add node$i $ip
        if [[ `echo $?` != 0 ]]
        then
                echo "16 error."
                break
        else
                echo "16 success."
        fi

	ceph-mon -i node$i --public-addr $ip
        if [[ `echo $?` != 0 ]]
        then
                echo "17 error."
                break
        else
                echo "17 success."
        fi

:<<block
	#systemctl reset-failed ceph-mon@node$i.service
	systemctl start ceph-mon@node$i
        if [[ `echo $?` != 0 ]]
        then
                echo "16 error."
                break
        else
                echo "16 success."
        fi

        systemctl enable ceph-mon@node$i
        if [[ `echo $?` != 0 ]]
        then
                echo "16 error."
                break
        else
                echo "16 success."
        fi

	ps -ef |grep ceph-mon
	#ceph osd lspools && ceph -s && ps -ef |grep ceph-mon
block

done

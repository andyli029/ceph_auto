#!/bin/bash
#http://docs.ceph.com/docs/hammer/install/manual-deployment/#monitor-bootstrapping
array=( 176 )
for i in ${array[@]}
do
        #systemctl reset-failed ceph-mon@node$i.service
        systemctl stop ceph-mon@node$i
        if [[ `echo $?` != 0 ]]
        then
                echo "1 error."
                break
        else
                echo "1 success."
        fi

        systemctl disable ceph-mon@node$i
        if [[ `echo $?` != 0 ]]
        then
                echo "2 error."
                break
        else
                echo "2 success."
        fi

	rm -f  /etc/ceph/ceph.conf
	if [[ `echo $?` != 0 ]]
        then
                echo "rm ceph.conf error."
                break
        else
                echo "rm ceph.conf success."
        fi

	rm -f /tmp/ceph.mon.keyring
        if [[ `echo $?` != 0 ]]
        then
                echo "8 error."
                break
        else
                echo "8 success."
        fi

		#/etc/init.d/ceph stop osd.$i
        rm -f /etc/ceph/ceph.client.admin.keyring
	if [[ `echo $?` != 0 ]]
        then
                echo "9 error."
                break
        else
                echo "9 success."
        fi

	#ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
        if [[ `echo $?` != 0 ]]
        then
                echo "10 error."
                break
        else
                echo "10 success."
        fi

	rm -f /tmp/monmap
        if [[ `echo $?` != 0 ]]
        then
                echo "11 error."
                break
        else
                echo "11 success."
        fi

        rm -rf /var/lib/ceph/mon/ceph-node$i
        if [[ `echo $?` != 0 ]]
        then
                echo "12 error."
                break
        else
                echo "12 success."
        fi

        rm -f /var/lib/ceph/mon/ceph-node$i/done
	if [[ `echo $?` != 0 ]]
        then
                echo "15 error."
                break
        else
                echo "15 success."
        fi

	#systemctl reset-failed ceph-mon@node$i.service
	systemctl stop ceph-mon@node$i
        if [[ `echo $?` != 0 ]]
        then
                echo "16 error."
                break
        else
                echo "16 success."
        fi

        systemctl disable ceph-mon@node$i
        if [[ `echo $?` != 0 ]]
        then
                echo "16 error."
                break
        else
                echo "16 success."
        fi

	ps -ef |grep ceph-mon
	#ceph osd lspools && ceph -s && ps -ef |grep ceph-mon
done

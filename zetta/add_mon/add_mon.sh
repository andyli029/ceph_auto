#!/bin/bash
#http://docs.ceph.com/docs/hammer/install/manual-deployment/#monitor-bootstrapping
ip=192.168.124.176 

array=( 176 )
for i in ${array[@]}
do
	cp ./ceph.conf /etc/ceph/ceph.conf
	if [[ `echo $?` != 0 ]]
        then
                echo "cp ceph.conf error."
                break
        else
                echo "cp ceph.conf success."
        fi


	ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
        if [[ `echo $?` != 0 ]]
        then
                echo "8 error."
                break
        else
                echo "8 success."
        fi

		#/etc/init.d/ceph stop osd.$i
        ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow'
	if [[ `echo $?` != 0 ]]
        then
                echo "9 error."
                break
        else
                echo "9 success."
        fi

	ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
        if [[ `echo $?` != 0 ]]
        then
                echo "10 error."
                break
        else
                echo "10 success."
        fi

	monmaptool --create --add node$i $ip --fsid a7f64266-0894-4f1e-a635-d0lizha0e993 /tmp/monmap	
        if [[ `echo $?` != 0 ]]
        then
                echo "11 error."
                break
        else
                echo "11 success."
        fi

        mkdir /var/lib/ceph/mon/ceph-node$i
        if [[ `echo $?` != 0 ]]
        then
                echo "12 error."
                break
        else
                echo "12 success."
        fi
.<<block
	chown ceph:ceph -R /var/lib/ceph/mon/ceph-node$i
	if [[ `echo $?` != 0 ]]
	then
                echo "12.1 error."
                break
        else
                echo "12.1 success."
        fi
block

	ceph-mon --mkfs -i node$i --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
        if [[ `echo $?` != 0 ]]
        then
                echo "13 error."
                break
        else
                echo "13 success."
        fi

        touch /var/lib/ceph/mon/ceph-node$i/done
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
done

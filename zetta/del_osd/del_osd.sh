#!/bin/bash
#http://docs.ceph.com/docs/hammer/install/manual-deployment/#monitor-bootstrapping
################ var ###### 
array=( 0 )
###########################

for i in ${array[@]}
do
###### var ######

	ceph osd out osd.${i}
	if [[ `echo $?` != 0 ]]
        then
                echo "1 error."
                break
        else
                echo "1 success."
        fi
	
	#kill -9 `ps -ef |grep ceph-osd|grep "id ${i}" | awk '{print $2}' |sed -n '1p'`
	systemctl stop ceph-osd@$i
        if [[ `echo $?` != 0 ]]
        then
                echo "6 error."
                break
        else
                echo "6 success."
        fi
        if [[ `echo $?` != 0 ]]
        then
                echo "1 error."
                break
        else
                echo "1 success."
        fi

	ceph osd crush remove osd.${i}	
	if [[ `echo $?` != 0 ]]
        then
                echo "2 error."
                break
        else
                echo "2 success."
        fi
	
	ceph auth del osd.${i}
        if [[ `echo $?` != 0 ]]
        then
                echo "3 error."
                break
        else
                echo "3 success."
        fi

	ceph osd rm osd.${i}
        if [[ `echo $?` != 0 ]]
        then
                echo "4 error."
                break
        else
                echo "4 success."
        fi

	systemctl disable ceph-osd@$i
        if [[ `echo $?` != 0 ]]
        then
                echo "5 error."
                break
        else
                echo "5 success."
        fi

	ps -ef |grep ceph-osd && ceph osd tree
	#ceph osd lspools && ceph -s && ps -ef |grep ceph-mon
done

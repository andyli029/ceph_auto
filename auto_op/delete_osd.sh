#!/bin/bash

array=( 4 6 9 12 16)
for i in ${array[@]}
do
        ceph osd out osd.$i
        if [[ `echo $?` != 0 ]]
        then
                echo "ceph osd out error."
                break
        else
                echo "ceph osd out success."
        fi

		#/etc/init.d/ceph stop osd.$i
        systemctl stop ceph-osd@$i
        if [[ `echo $?` != 0 ]]
        then
                echo "/etc/init.d/ceph stop osd.$i error."
                break
        else
                echo "/etc/init.d/ceph stop osd.$i success."
        fi

        ceph osd crush remove osd.$i
        if [[ `echo $?` != 0 ]]
        then
                echo "ceph osd crush remove osd.$i error."
                break
        else
                echo "ceph osd crush remove osd.$i success."
        fi

        ceph auth del osd.$i
        if [[ `echo $?` != 0 ]]
        then
                echo "ceph auth del osd.$i error."
                break
        else
                echo "ceph auth del osd.$i success."
        fi

        ceph osd rm osd.$i
        if [[ `echo $?` != 0 ]]
        then
                echo "ceph osd rm osd.$i error."
                break
        else
                echo "ceph osd rm osd.$i success."
        fi
done

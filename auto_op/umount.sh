#!/bin/bash

array=(0 4 6 9 12 16) 
for i in ${array[@]}
do
        umount /var/lib/ceph/osd/ceph-$i
        if [[ `echo $?` != 0 ]]
        then
                echo "umount /var/lib/ceph/osd/ceph.$i error."
                break
        else
                echo "umount /var/lib/ceph/osd/ceph.$i success."
        fi 
done

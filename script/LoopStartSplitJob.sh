#!/bin/bash 
source /tools/slurm.env 

for data_date in 201903{17..31};
do 
    for data_part_id in {00..04};\
    do 
    num=$(sinfo -p m42-test|grep idle|awk '{print $4}')
        if [ "$num" -ge 4  ];then 
            echo "echo $num ";
            bash /mnt/NFS2/zhangyanchao/tools/script/run_slurm_split.sh $data_date $data_part_id >/mnt/NFS2/zhangyanchao/tools/script/log/${date_date}_${data_part_id}.src.log 2>&1 &
        fi
    done
    sleep 300

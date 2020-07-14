#!/bin/bash

function init(){
    decode_workspace=/mnt/NFS1/zhangyanchao/src_mul_channel/multi_channel_${data_date}_${data_part_id}/decode_workspace_xdyx
    audio_lst_file=/mnt/NFS5/multi_channel_${data_date}_${data_part_id}/merge_total_bv.lst
    
    package_size=130000

    [ -e $decode_workspace ] || mkdir -p $decode_workspace/audio_source
#    rm -f  $decode_workspace/audio_source/*
    split -l $package_size -a 3 -d $audio_lst_file $decode_workspace/audio_source/audio_part_
    ls $decode_workspace/audio_source/audio_part_* > $decode_workspace/audio_part.lst
}


function multi_thread_init(){
    [ -e /tmp/xdyx_fd ] && rm /tmp/xdyx_fd
    mkfifo /tmp/xdyx_fd
    exec 5<>/tmp/xdyx_fd
    rm /tmp/xdyx_fd
    for((i=0; i<8; i++));do
        echo >&5
    done
}

function multi_thread_clear(){
    exec 5>&-
    exec 5<&-
}

function main(){
    multi_thread_init

    init
    
    task_name=${data_date}_${data_part_id}
    cat $decode_workspace/audio_part.lst | while read line; do
        echo "prepare task: $line"
        read -u5
        {
            echo "start task: $line"
            lst_name=`basename $line`
            sh $decode_script ${task_name}.${lst_name} $decode_workspace $line   
            echo "end task: $line"
            echo >&5
        }&
    done 
    #done < $decode_workspace/audio_part.lst
    wait
    
    # 解码执行完成后，结果可能未拷贝到共享盘，等待60s
    sleep 60s
    cat $decode_workspace/*.out > $decode_workspace/../decode_xdyx.out
    
    echo "decode done."
    multi_thread_clear
}

cur_dir=$(cd `dirname $0`; pwd)
decode_script=${cur_dir}/decode_offline/start_decode_offline_xdyx.sh

data_date="20190316"
data_part_id="02"

main

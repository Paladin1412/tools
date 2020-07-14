#!/bin/bash

deco_box_env=/mnt/NFS1/zhangyanchao/decoder_env/dynamic-wfst.xiaodubox
deco_home_env=/mnt/NFS1/zhangyanchao/decoder_env/dynamic-wfst.xiaoduhome

function init(){
    decode_workspace=/mnt/NFS1/zhangyanchao/src_mul_channel/multi_channel_${data_date}_${data_part_id}/decode_workspace_xdyx
    audio_lst_file=/mnt/NFS3/zhangyanchao/src_mul_channel/multi_channel_${data_date}_${data_part_id}/merge_total_bv.lst
    
    package_size=130000
    [ -e $decode_workspace ] || mkdir -p $decode_workspace/audio_source
    rm -f  $decode_workspace/audio_source/*
    split -l $package_size -a 3 -d $audio_lst_file $decode_workspace/audio_source/audio_part_
    ls $decode_workspace/audio_source/audio_part_* > $decode_workspace/audio_part.lst
}

source /tools/slur.env
for ff in `ls $decode_workspace/audio_source/audio_part_*`;
do 
srun -p AM2_K1200 bash deco_box_env/star.sh 

data_date="20190312"
data_part_id="01"

    [ -d /home/speech/decoder_env ] || cp -r /mnt/NFS2/zhangyanchao/decoder_env /home/speech/


for ff in {004..007};do srun -p AM2_K1200 -n 1 -N 1  --job-name=20190312_01_${ff}_xdyx /home/speech/decoder_env/dynamic-wfst.xiaodubox/start.sh /mnt/NFS1/zhangyanchao/src_mul_channel/multi_channel_20190312_01/decode_workspace_xdyx/audio_source/audio_part_${ff} & done

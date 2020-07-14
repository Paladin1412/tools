#!/bin/bash
#data_date="20190313"
#data_part_id="04"
data_date=$1
data_part_id=$2
for ff in {1..2};do 
batch_pkg=/mnt/NFS1/zhangyanchao/label/multi_channel_${data_date}_${data_part_id}/batch_$ff/merge_output
cut -f1 $batch_pkg |sed "s#^#/home/disk7/mark_data/src_mul_channel/${data_date}_${data_part_id}/audio_8kwav/16000_#g"|sed 's#$#.wav#' > tmp_create_label_lst/${data_date}_${data_part_id}.scp
python /home/tools/count_pcm_list_duration.py tmp_create_label_lst/${data_date}_${data_part_id}.scp  > tmp_create_label_lst/${data_date}_${data_part_id}.time

paste tmp_create_label_lst/${data_date}_${data_part_id}.time  /mnt/NFS1/zhangyanchao/label/multi_channel_${data_date}_${data_part_id}/batch_$ff/merge_output |awk -F'\t' '{print $1"\t"$2"\t"$4"\t"$5"\t"$6"\t"$7}'|sed 's#/home/disk7/mark_data/#http://10.210.20.31:8080/#g' > tmp_create_label_lst/multi_channel_${data_date}_${data_part_id}.${ff}.L
done

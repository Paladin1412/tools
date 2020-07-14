#!/bin/bash

function init(){

    # 输出目录
    output_dir=/mnt/NFS5/multi_channel_${data_date}_${data_part_id}/
    #output_dir=/mnt/NFS3/zhangyanchao/src_mul_channel/multi_channel_${data_date}_${data_part_id}/
    #output_dir=/home/slurm/data/SPEECH_KM_Data/zhangyanchao/src_mul_channel/process_audio_pcm/multi_channel_${data_date}_${data_part_id}/
    [ -d $output_dir ] || mkdir -p ${output_dir}/log
    
    # 获取原来多路音频列表
    ori_id_list=${ori_data_dir}/orid
    [ -e $ori_id_list ] || { echo "ori id lst file not found: $ori_id_list. exit."; exit 1; }
    sed "s#^#${ori_data_dir}/ori-audio/16000_#" $ori_id_list > ${output_dir}/ori_audio.lst
    
    # 按任务个数拆成多份
    source_file_lst=${output_dir}/ori_audio.lst
    total_file_num=`wc -l $source_file_lst | cut -d\  -f1`
    per_file_num=$(($total_file_num/$task_num+1))
    echo $per_file_num  $source_file_lst ${source_file_lst}
    split -l $per_file_num -d $source_file_lst ${source_file_lst}_
}


function submit_to_slurm(){
    # 提交任务到集群处理
    audio_lst=$1
    tmp_task_name=$2
    source /tools/slurm.env
    #split_multi_script=/mnt/QA_disk2/chenzeming01/multi_channel_data_process/parse_all.sh
    split_multi_script=/mnt/NFS2/zhangyanchao/tools/script/parse_all.sh
    srun -p $slurm_group -n 1 -N 1 --job-name=$tmp_task_name \
        sh $split_multi_script $audio_lst $output_dir/${tmp_task_name} $tmp_task_name $thread_num
}

function main(){

    init 

    task_name="${data_date}_${data_part_id}"
    
    i=0
    while [ $i -lt $task_num ]; do
        file_idx=`printf "%02d" $i`
        submit_to_slurm ${source_file_lst}_${file_idx} ${task_name}_${file_idx} > ${output_dir}/log/${task_name}_${file_idx}.log 2>&1 &
        i=$(($i+1))
    done
    wait

    cat ${output_dir}/total_${data_date}_${data_part_id}_*.lst > ${output_dir}/merge_total.lst
    sed "s/$/.bv/" ${output_dir}/merge_total.lst > ${output_dir}/merge_total_bv.lst
    sed "s/$/.pcm/" ${output_dir}/merge_total.lst > ${output_dir}/merge_total_pcm.lst

}


# slurm任务个数（使用机器数）
task_num=4
# 每个任务线程数
thread_num=30
# 使用集群名
slurm_group=m42-test
#slurm_group=AM2_K1200
#原始数据base目录
ori_data_base_dir=/mnt/HDDFS4/speech_data/zhangfangping/

data_date="20190317"
data_part_id="01"
ori_data_dir=${ori_data_base_dir}/${data_date}/${data_part_id}

main


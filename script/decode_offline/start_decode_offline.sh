#!/bin/bash

:<<\###
#--- 解码任务名称
decode_job_name=default
#--- 解码工作目录
decode_output_dir=/mnt/QA_disk2/chenzeming01/test
#--- 解码器conf
decode_conf=/mnt/QA_disk2/am_train_data/car/decode_data/dynamic-wfst-1788/conf
#--- 解码器data
data_dir=/mnt/QA_disk2/am_train_data/car/decode_data/dynamic-wfst-1788/data_car.20181220
#--- 解码器lm
lm_dir=/mnt/QA_disk2/am_train_data/car/decode_data/dynamic-wfst-1788/lm_car.20181220
#--- 地域解码配置，打开配置生效，注释掉不生效
#fsn_dir=/mnt/AM2_disk9/sunjianwei01/map_decode_source/map_diyu_source_20181210/fsn
#--- 模型列表文件
model_file=/mnt/QA_disk2/chenzeming01/test/model_lst
#--- 解码bin
bin=/mnt/QA_disk2/am_train_data/car/decode_data/dynamic-wfst-1788/bin/fpga/dynamic_wfst_offline
#--- wer工具
wer_bin=/mnt/QA_disk2/am_train_tools/wer-0515
#--- 测试数据路径，如果lst文件中音频路径是全路径，可不配置
testdata_dir=/mnt/QA_disk2/am_train_data/car/test_data
#--- 测试数据集列表
testdata_lst=/mnt/QA_disk2/am_train_data/car/test_data/czm_testset_car_cnen_2.lst
#--- 解码集群
slurm_group=m42-test
#---===================================end======================================
###
#slurm_group=AM2_K1200


function decode_init(){

    # 校验必填参数
    [ -z $decode_job_name ] && { echo "Parameter <decode_job_name> can not be empty.";  exit 1; }
    [ -z $decode_output_dir ] && { echo "Parameter <decode_output_dir> can not be empty.";  exit 1; }
    [ -z $decode_conf ] && { echo "Parameter <decode_conf> can not be empty.";  exit 1; }
    [ -z $data_dir ] && { echo "Parameter <data_dir> can not be empty.";  exit 1; }
    #[ -z $lm_dir ] && { echo "Parameter <lm_dir> can not be empty.";  exit 1; }
    [ -z $bin ] && { echo "Parameter <bin> can not be empty.";  exit 1; }
    [ -z $model_file ] && { echo "Parameter <model_file> can not be empty.";  exit 1; }
    #[ -z $wer_bin ] && { echo "Parameter <wer_bin> can not be empty.";  exit 1; }
    [ -z $testdata_lst ] && { echo "Parameter <testdata_lst> can not be empty.";  exit 1; }
    [ -z $slurm_group ] && { echo "Parameter <slurm_group> can not be empty.";  exit 1; }

    # 校验配置是否存在
    [ -e $decode_conf ] || { echo "Parameter <$decode_conf> not exist.";  exit 1; }
    [ -e $data_dir ] || { echo "Parameter <$data_dir> not exist.";  exit 1; }
    #[ -e $lm_dir ] || { echo "Parameter <$lm_dir> not exist.";  exit 1; }
    [ -e $bin ] || { echo "Parameter <$bin> not exist.";  exit 1; }
    [ -e $model_file ] || { echo "Parameter <$model_file> not exist.";  exit 1; }
    #[ -e $wer_bin ] || { echo "Parameter <$wer_bin> not exist.";  exit 1; }
    [ -e $testdata_lst ] || { echo "Parameter <$testdata_lst> not exist.";  exit 1; }

    [ -e $decode_output_dir ] || { mkdir -p $decode_output_dir; }
    decode_dir=$decode_output_dir/
    [ -d $decode_dir/${decode_job_name}_conf ] && rm -rf $decode_dir/${decode_job_name}_conf
    cp -rf $decode_conf $decode_dir/${decode_job_name}_conf
    decode_conf=$decode_dir/${decode_job_name}_conf
    
    log_file=${decode_dir}/decode_log/decode_${decode_job_name}.log
    source ${cur_dir}/common_log.sh
    log_init ${log_file}
}


function start_remote_decode(){
    log_info "start decode on the remote cluster."
    #source /mnt/QA_disk2/am_train_tools/set_env.sh
    source  /mnt/NFS2/zhangyanchao/slurm_old_env.rc
    cp ${cur_dir}/run_on_remote_decode_single.sh $decode_dir
    remote_decode=${decode_dir}/run_on_remote_decode_single.sh

    options_str="
        --decode_output_dir $decode_dir
        --conf_dir $decode_conf
        --data_dir $data_dir
        --model_file $model_file
        --testdata_lst $testdata_lst
        --testdata_dir $testdata_dir
        --decode_bin $bin
        --model_file $model_file
    "
    if [ -n "$fsn_dir" ]; then
        options_str="$options_str --fsn_dir $fsn_dir"
    fi
    if [ -n "$lm_dir" ]; then
        options_str="$options_str --lm_dir $lm_dir"
    fi
    if [ -n "$wer_bin" ]; then
        options_str="$options_str --wer_bin $wer_bin"
    fi
    srun -p ${slurm_group} -n 1 -N 1 \
        --job-name=$decode_job_name sh $remote_decode $options_str
}


function main(){

    decode_init

    start_remote_decode

    rm -rf $decode_conf
}


cur_dir=$(cd `dirname $0`; pwd)

main


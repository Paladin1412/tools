#!/bin/bash

#--- 解码任务名称
decode_job_name=xdyx_$1
#--- 解码工作目录
decode_output_dir=$2
#--- 解码器conf
decode_conf=/mnt/QA_disk2/am_train_data/xiaoduyinxiang/dynamic-wfst.box/conf
#--- 解码器data
data_dir=/mnt/QA_disk2/am_train_data/xiaoduyinxiang/dynamic-wfst.box/data_xdyx.20190412
#--- 解码器lm
#lm_dir=/mnt/QA_disk2/chenzeming01/ime_dataloop/ime_decoders/decode_ime_dongbei/lm.20190219
#--- 地域解码配置，打开配置生效，注释掉不生效
#fsn_dir=/mnt/AM2_disk9/sunjianwei01/map_decode_source/map_diyu_source_20181210/fsn
#--- 模型列表文件
model_file=/mnt/QA_disk2/am_train_data/xiaoduyinxiang/online_version_1/final_3ring_xiaodu_ver1.cpu.mdl
#--- 解码bin
bin=/mnt/QA_disk2/am_train_data/xiaoduyinxiang/dynamic-wfst.box/bin/dynamic_wfst_Stastic
#--- wer工具
#wer_bin=/mnt/QA_disk2/am_train_tools/wer-0515
#--- 测试数据路径，如果lst文件中音频路径是全路径，可不配置
testdata_dir=/mnt/QA_disk2/am_train_data/car/test_data
#--- 测试数据集列表
testdata_lst=$3
#--- 解码集群
#slurm_group=m42-test
#slurm_group=AM2_K1200
slurm_group=m42
#---===================================end======================================

cur_dir=$(cd `dirname $0`; pwd)

source ${cur_dir}/start_decode_offline.sh
